From: =?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d@gmail.com>
Subject: Re: linux-2..6.33-rc7 and b43
Date: Sun, 14 Feb 2010 19:59:54 +0100
Message-ID: <69e28c911002141059y57fb2097x5613c25ad1c616da@mail.gmail.com>
References: <4B77C819.9050602@mandriva.org> <4B782670.9080001@lwfinger.net>
	<4B784498.8030509@mandriva.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Backlund <tmb@mandriva.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:50011 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149Ab0BNTAS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 14:00:18 -0500
In-Reply-To: <4B784498.8030509@mandriva.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 14, 2010 at 7:44 PM, Thomas Backlund <tmb@mandriva.org> wro=
te:
> Larry Finger skrev 14.2.2010 18:36:
>>
>> On 02/14/2010 03:53 AM, Thomas Backlund wrote:
>>>
>>> Hi,
>>> (please cc me on replies)
>>>
>>> We have a user that tried out b43, but got this in the logs:
>>>
>>> --- cut ---
>>> 65858:Feb =A09 22:05:16 elmo kernel: b43-phy2 ERROR: This device do=
es not
>>> support DMA on your system. Please use PIO instead. 65859:Feb =A09
>>> 22:05:16 elmo kernel: b43-phy2 ERROR: CONFIG_B43_FORCE_PIO must
>>> be set in your kernel configuration.
>>> 65860:Feb =A09 22:05:16 elmo kernel: b43-phy2 debug: Adding Interfa=
ce type
>>> 2
>>> 65861:Feb =A09 22:05:16 elmo kernel: b43-phy2 ERROR: Fatal DMA erro=
r:
>>> 0x00000400, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000=
000
>>>
>>> 65862:Feb =A09 22:05:16 elmo kernel: b43-phy2 ERROR: This device do=
es not
>>> support DMA on your system. Please use PIO instead.
>>> 65863:Feb =A09 22:05:16 elmo kernel: b43-phy2 ERROR: CONFIG_B43_FOR=
CE_PIO
>>> must be set in your kernel configuration.
>>> --- cut ---
>>>
>>>
>>>
>>> But reading the Kconfig help, it states:
>>> --- cut ---
>>> config B43_FORCE_PIO
>>> =A0 =A0 =A0 =A0 bool "Force usage of PIO instead of DMA"
>>> =A0 =A0 =A0 =A0 depends on B43&& =A0B43_DEBUG
>>> =A0 =A0 =A0 =A0 ---help---
>>> =A0 =A0 =A0 =A0 =A0 This will disable DMA and always enable PIO ins=
tead.
>>>
>>> =A0 =A0 =A0 =A0 =A0 Say N!
>>> =A0 =A0 =A0 =A0 =A0 This is only for debugging the PIO engine code.=
 You do
>>> =A0 =A0 =A0 =A0 =A0 _NOT_ want to enable this.
>>> --- cut ---
>>>
>>>
>>> So,
>>> wich one is it ?
>>>
>>> Do I belive the dmesg output, or the Kconfig ?
>>>
>>> Note,
>>> the b43 works for the user if he enable the CONFIG_B43_FORCE_PIO.
>>>
>>> But I'm thinking of this problem from a distro point of view.
>>> Will it break for others if I enable it ?
>>
>>> From a distro point of view, you would not want to set FORCE_PIO as=
 the
>>
>> performance penalty would be very large.
>>
>
> As I suspected.
> Thanks for confirming it.
>
>> You do not give the specific details on the problem system; however,=
 it is
>> probably a BCM4312 802.11 b/g device with PCI ID 14e4:4315 being use=
d with
>> an
>> Atom processor in a netbook. We have no fix.
>>
>
> Sorry about the missing info...
> I asked a few times from the user, and got no reponse until today a f=
ew
> hours after your response...
>
> It is indeed a BCM4312 802.11 b/g device with PCI ID 14e4:4315 on a D=
ell
> laptop with a Intel ICH9M series chipset and a Intel Core(TM)2 Duo CP=
U T7250
> @ 2.00GHz.

Weird... that's not an Intel Atom, but a Core 2 Duo, standard-voltage.
Mind posting any more details on this system?

>
>> In the 2.6.34 code, b43 will be changed to allow the selection of PI=
O mode
>> at
>> run time rather than compile time. For a distro, this method is clea=
rly
>> superior. Those users that need PIO can select it without forcing th=
e
>> performance penalty on everyone. The patch was too late for the 2.6.=
33
>> merge,
>> and too intrusive to be applied to 2.6.33-rcX. It has been present i=
n the
>> wireless-testing code base for 2 months with no trouble reported, th=
us it
>> should
>> be safe for inclusion in your kernels. The relevant patch is attache=
d.
>>
>
> Nice solution.
>
> What about making it autodetected ?
> Or is it only a "last resort" with the hopes of getting the issue fix=
ed?
>
> Anyway, thanks for the patch.
>
> --
> Thomas
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Vista: [V]iruses, [I]ntruders, [S]pyware, [T]rojans and [A]dware. :-)
