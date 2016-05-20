From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: 4.5.0 on sun7i-a20-olinuxino-lime2: libphy: PHY stmmac-0:ffffffff
 not found (regression from rc7)
Date: Fri, 20 May 2016 11:36:36 +0100
Message-ID: <573EE8B4.1050701@arm.com>
References: <56E9413D.9010902@a20.net> <56E945FF.6080005@arm.com>
 <56E94CF4.2060607@arm.com> <56E95B57.1090100@suse.de>
 <56E9776F.3070102@a20.net> <56E99B0C.2070609@arm.com>
 <56E9F2B8.1030605@a20.net> <20160317075202.16b14ed6@arm.com>
 <CAHsu+b-t_r93XKLJTUcin6xjhOrFVn3_60vwHkbRt3iHK28CbA@mail.gmail.com>
 <573EC33D.2010209@arm.com> <573EC77A.2000800@st.com>
 <CAHsu+b9BrqBLdCpsPpetc_4_EaFVGBdDHtoeeCqqzsCG3Wpsig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
	Bert Lindner <bert@a20.net>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Robin Murphy <robin.murphy@arm.com>,
	=?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>,
	linux-arm-kernel@lists.infradead.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-sunxi@googlegroups.com
To: Andre Heider <a.heider@gmail.com>,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:40414 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932424AbcETKgk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2016 06:36:40 -0400
In-Reply-To: <CAHsu+b9BrqBLdCpsPpetc_4_EaFVGBdDHtoeeCqqzsCG3Wpsig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/05/16 11:30, Andre Heider wrote:
> Hi,
>=20
> On Fri, May 20, 2016 at 10:14 AM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
>> On 5/20/2016 9:56 AM, Marc Zyngier wrote:
>>>
>>> On 20/05/16 06:44, Andre Heider wrote:
>>>>
>>>> Giuseppe, Alexandre, et al.,
>>>>
>>>> On Thu, Mar 17, 2016 at 8:52 AM, Marc Zyngier <marc.zyngier@arm.co=
m>
>>>> wrote:
>>>>>
>>>>> On Thu, 17 Mar 2016 00:56:40 +0100
>>>>> Bert Lindner <bert@a20.net> wrote:
>>>>>>
>>>>>> On 2016-03-16 18:42, Marc Zyngier wrote:
>>>>>>>
>>>>>>> On 16/03/16 15:10, Bert Lindner wrote:
>>>>>>>>
>>>>>>>> On 2016-03-16 14:10, Andreas F=C3=A4rber wrote:
>>>>>>>>>
>>>>>>>>> Am 16.03.2016 um 13:09 schrieb Robin Murphy:
>>>>>>>>>>
>>>>>>>>>> On 16/03/16 11:39, Marc Zyngier wrote:
>>>>>>>>>>>
>>>>>>>>>>> On 16/03/16 11:19, Bert Lindner wrote:
>>>>
>>>> ...
>>>>>>>>>>>>
>>>>>>>>>>>> For the board sun7i-a20-olinuxino-lime2, there seems to be=
 a
>>>>>>>>>>>> problem
>>>>>>>>>>>> with the eth0 PHY in mainline kernel 4.5.0 that developed =
since
>>>>>>>>>>>> 4.5.0-rc7. Ethernet does not work, although eth0 is report=
ed:
>>>>
>>>> ...
>>>>>>>>>>>>
>>>>>>>>>>>> [    9.767125] NET: Registered protocol family 10
>>>>>>>>>>>> [   10.357405] libphy: PHY stmmac-0:ffffffff not found
>>>>>>>>>>>> [   10.362382] eth0: Could not attach to PHY
>>>>>>>>>>>> [   10.366557] stmmac_open: Cannot attach to PHY (error: -=
19)
>>>>
>>>> ...
>>>>>>>>>
>>>>>>>>> v4 fixes for 4.5 are here:
>>>>>>>>>
>>>>>>>>> https://patchwork.ozlabs.org/patch/598195/ (revert)
>>>>>>>>> https://patchwork.ozlabs.org/patch/598196/
>>>>
>>>> ...
>>>>>>>
>>>>>>> Good to know, thanks. Could you also give the potential fix a g=
o (as
>>>>>>> mentioned by Andreas)? Just to make sure that whatever gets mer=
ged
>>>>>>> next
>>>>>>> will actually fix the issue.
>>>>>>
>>>>>>
>>>>>> Yes sure, it took a while because I had to travel. Confirmed, th=
e
>>>>>> v4-for-4.5 fix works well for me, on sun7i-a20-olinuxino-lime2:
>>>>>>
>>>>>> root@lime2-079f:~# cat /proc/version
>>>>>> Linux version 4.5.0-598195-598196-v4 (root@lime2-079f) (gcc vers=
ion
>>>>>> 4.9.1 (Ubuntu/Linaro 4.9.1-16ubuntu6) ) #1 SMP Wed Mar 16 16:44:=
22 UTC
>>>>>> 2016
>>>>>>
>>>>>> dmesg:
>>>>>> [    8.245273] NET: Registered protocol family 10
>>>>>> [    9.297406]  RX IPC Checksum Offload disabled
>>>>>> [    9.297460]  No MAC Management Counters available
>>>>>> [    9.297951] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not read=
y
>>>>>> [   16.285658] sun7i-dwmac 1c50000.ethernet eth0: Link is Up -
>>>>>> 1Gbps/Full - flow control rx/tx
>>>>>> [   16.285798] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes=
 ready
>>>>>>
>>>>>> The board is connected to my laptop rather than to a switch, so =
that
>>>>>> might be where the flow control message comes from (not sure). A=
nyway
>>>>>> ethernet works.
>>>>>
>>>>>
>>>>> Cool, many thanks for taking the time to test and report.
>>>>>
>>>>> Hopefully Giuseppe will get this merged quickly enough in mainlin=
e, and
>>>>> it should then trickle into a 4.5-stable release (cc-ing stable o=
n
>>>>> these patches would probably be a good idea, BTW).
>>>>
>>>>
>>>> stmmac is broken on at least Lime2, BananaPi and Cubieboard2 since
>>>> v4.5 [0], including all five stable releases :(
>>>
>>>
>>> All the A20 platforms are dead, actually.
>>>
>>>> The v4.5 patches quoted above are already +4 weeks old, could we
>>>> please get them into stable?
>>>
>>>
>>> For that, the maintainer would have needed to CC stable, which he
>>> didn't. I'd expect someone who cares to send these patches to stabl=
e.
>>> It'd be better if the maintainer would do it himself though.
>>
>>
>> sure, I can send the patches to stable (sorry if I missed to add
>> stable ML on CC).
>>
>> Andre, I have not clear if the train of patches actually fix the
>> issue or if you need my support to fix something else. In that case
>> I need some input for debugging (e.g. kernel log).
>=20
> Bert already confirmed that those two patches fixes stmmac on his
> Lime2, so I assume that it fixes the issue for all A20 platforms.
>=20
>> let me know, is it enough to re-send the patches only?
>=20
> Just a resend with cc:stable :)

Not quite. Please read Documentation/stable_kernel_rules.txt, and the
section that concerns networking patches (and then consult
Documentation/networking/netdev-FAQ.txt which has all the details).

Thanks,

	M.
--=20
Jazz is not dead. It just smells funny...
