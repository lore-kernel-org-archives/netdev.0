From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] igb: fix kexec with igb
Date: Sat, 07 Mar 2009 10:20:42 -0800
Message-ID: <m1ocwddwjp.fsf@fess.ebiederm.org>
References: <49B1F934.5050006@kernel.org>
	<4807377b0903062318q15ba52a7n82d4c9399b8a7fa8@mail.gmail.com>
	<86802c440903062331j22aa57c7r93c84da880a8e572@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:37164 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbZCGSUt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 13:20:49 -0500
In-Reply-To: <86802c440903062331j22aa57c7r93c84da880a8e572@mail.gmail.com> (Yinghai Lu's message of "Fri\, 6 Mar 2009 23\:31\:17 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yinghai Lu <yinghai@kernel.org> writes:

> On Fri, Mar 6, 2009 at 11:18 PM, Jesse Brandeburg
> <jesse.brandeburg@gmail.com> wrote:
>> On Fri, Mar 6, 2009 at 8:33 PM, Yinghai Lu <yinghai@kernel.org> wrot=
e:
>>>
>>> Impact: could probe igb
>>>
>>> Found one system with 82575EB, in the kernel that is kexeced, probe=
 igb
>>> failed with -2.
>>>
>>> it looks like the same behavior happened on forcedeth.
>>>
>>> try to check system_state to make sure if put it on D3
>>>
>>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>>>
>>> ---
>>> =C2=A0drivers/net/igb/igb_main.c | =C2=A0 19 ++++++++++++++-----
>>> =C2=A01 file changed, 14 insertions(+), 5 deletions(-)
>>
>> I see the point of the patch, but I know for a fact that ixgbe when
>> enabled for MSI-X also doesn't work with kexec.
>>
>> so my questions are:
>> are you going to change every driver?
>
> i tend to only change driver that i have related HW.
>
>> why can't this be fixed in core kernel code instead?
> will check it.
>
>> Shouldn't pci_enable_device take it out of D3?
>> Or maybe it should be taken out of D3 immediately if someone tries t=
o
>> ioremap any of the BARx registers?
>
>
> looks like second kernel can not detect the state any more.

I know this has historically been a problem with the e1000 NICs.
Placing the hardware in a state they can not get them out of on
the reboot path.

Last I heard (a couple of weeks ago?) we had code to bring devices out
of a low power state that was working for the e1000 driver.

YH can you look and see if you can find that code and if it works?

<rant>
=46rankly I don't understand why anyone would want to power down a devi=
ce
when they are rebooting or shutting down a computer.  That is a
system state change.  But it seems to be bleed over from the confusion
that has been the power management code.
</rant>

If we can teach the kernel to handle this case with the proper enables
and disables that would be great.  Otherwise let's look at getting the
responsibilities of the various methods sorted out so we can at least
say with certainty what the various methods are supposed to do and
not do.

Eric
