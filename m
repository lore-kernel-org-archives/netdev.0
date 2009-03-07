From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH] igb: fix kexec with igb
Date: Sat, 7 Mar 2009 10:50:27 -0800
Message-ID: <86802c440903071050y453c7648x653d3e2073a33c1e@mail.gmail.com>
References: <49B1F934.5050006@kernel.org>
	 <4807377b0903062318q15ba52a7n82d4c9399b8a7fa8@mail.gmail.com>
	 <86802c440903062331j22aa57c7r93c84da880a8e572@mail.gmail.com>
	 <m1ocwddwjp.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:44905 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806AbZCGSu3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 13:50:29 -0500
In-Reply-To: <m1ocwddwjp.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 7, 2009 at 10:20 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Yinghai Lu <yinghai@kernel.org> writes:
>
>> On Fri, Mar 6, 2009 at 11:18 PM, Jesse Brandeburg
>> <jesse.brandeburg@gmail.com> wrote:
>>> On Fri, Mar 6, 2009 at 8:33 PM, Yinghai Lu <yinghai@kernel.org> wro=
te:
>>>>
>>>> Impact: could probe igb
>>>>
>>>> Found one system with 82575EB, in the kernel that is kexeced, prob=
e igb
>>>> failed with -2.
>>>>
>>>> it looks like the same behavior happened on forcedeth.
>>>>
>>>> try to check system_state to make sure if put it on D3
>>>>
>>>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>>>>
>>>> ---
>>>> =A0drivers/net/igb/igb_main.c | =A0 19 ++++++++++++++-----
>>>> =A01 file changed, 14 insertions(+), 5 deletions(-)
>>>
>>> I see the point of the patch, but I know for a fact that ixgbe when
>>> enabled for MSI-X also doesn't work with kexec.
>>>
>>> so my questions are:
>>> are you going to change every driver?
>>
>> i tend to only change driver that i have related HW.
>>
>>> why can't this be fixed in core kernel code instead?
>> will check it.
>>
>>> Shouldn't pci_enable_device take it out of D3?
>>> Or maybe it should be taken out of D3 immediately if someone tries =
to
>>> ioremap any of the BARx registers?
>>
>>
>> looks like second kernel can not detect the state any more.
>
> I know this has historically been a problem with the e1000 NICs.
> Placing the hardware in a state they can not get them out of on
> the reboot path.
>
> Last I heard (a couple of weeks ago?) we had code to bring devices ou=
t
> of a low power state that was working for the e1000 driver.

in net-next tree?

>
> YH can you look and see if you can find that code and if it works?

it seems e1000 and e1000e works well for a long time.

>
> <rant>
> Frankly I don't understand why anyone would want to power down a devi=
ce
> when they are rebooting or shutting down a computer. =A0That is a
> system state change. =A0But it seems to be bleed over from the confus=
ion
> that has been the power management code.
> </rant>

agreed.

>
> If we can teach the kernel to handle this case with the proper enable=
s
> and disables that would be great. =A0Otherwise let's look at getting =
the
> responsibilities of the various methods sorted out so we can at least
> say with certainty what the various methods are supposed to do and
> not do.

root cause could be some BIOS/acpi lying to Kernel about device state q=
uerying.

for igb, it only has problem on one platform. but other one platform is=
 ok.
for forcedeth, it seems all platform has the problem, aka you can not
put it in D3 in kexec path.

YH
