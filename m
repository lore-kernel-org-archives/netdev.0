From: Thomas Backlund <tmb@mandriva.org>
Subject: Re: linux-2..6.33-rc7 and b43
Date: Sun, 14 Feb 2010 21:18:00 +0200
Message-ID: <4B784C68.8020402@mandriva.org>
References: <4B77C819.9050602@mandriva.org> <4B782670.9080001@lwfinger.net> 	<4B784498.8030509@mandriva.org> <69e28c911002141059y57fb2097x5613c25ad1c616da@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mbox1.netikka.net ([213.250.81.202]:43198 "EHLO
	mbox1.netikka.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858Ab0BNTSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 14:18:03 -0500
In-Reply-To: <69e28c911002141059y57fb2097x5613c25ad1c616da@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

G=E1bor Stefanik skrev 14.2.2010 20:59:
> On Sun, Feb 14, 2010 at 7:44 PM, Thomas Backlund<tmb@mandriva.org>  w=
rote:
>> Larry Finger skrev 14.2.2010 18:36:
>>>
>>> On 02/14/2010 03:53 AM, Thomas Backlund wrote:
>>>>
>>>> Hi,
>>>> (please cc me on replies)
>>>>
>>>> We have a user that tried out b43, but got this in the logs:
>>>>
>>>> --- cut ---
>>>> 65858:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: This device doe=
s not
>>>> support DMA on your system. Please use PIO instead. 65859:Feb  9
>>>> 22:05:16 elmo kernel: b43-phy2 ERROR: CONFIG_B43_FORCE_PIO must
>>>> be set in your kernel configuration.
>>>> 65860:Feb  9 22:05:16 elmo kernel: b43-phy2 debug: Adding Interfac=
e type
>>>> 2
>>>> 65861:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: Fatal DMA error=
:
>>>> 0x00000400, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x0000=
0000
>>>>
>>>> 65862:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: This device doe=
s not
>>>> support DMA on your system. Please use PIO instead.
>>>> 65863:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: CONFIG_B43_FORC=
E_PIO
>>>> must be set in your kernel configuration.
>>>> --- cut ---
>>>>
>>>>
>>>>
>>>> But reading the Kconfig help, it states:
>>>> --- cut ---
>>>> config B43_FORCE_PIO
>>>>          bool "Force usage of PIO instead of DMA"
>>>>          depends on B43&&    B43_DEBUG
>>>>          ---help---
>>>>            This will disable DMA and always enable PIO instead.
>>>>
>>>>            Say N!
>>>>            This is only for debugging the PIO engine code. You do
>>>>            _NOT_ want to enable this.
>>>> --- cut ---
>>>>
>>>>
>>>> So,
>>>> wich one is it ?
>>>>
>>>> Do I belive the dmesg output, or the Kconfig ?
>>>>
>>>> Note,
>>>> the b43 works for the user if he enable the CONFIG_B43_FORCE_PIO.
>>>>
>>>> But I'm thinking of this problem from a distro point of view.
>>>> Will it break for others if I enable it ?
>>>
>>>>  From a distro point of view, you would not want to set FORCE_PIO =
as the
>>>
>>> performance penalty would be very large.
>>>
>>
>> As I suspected.
>> Thanks for confirming it.
>>
>>> You do not give the specific details on the problem system; however=
, it is
>>> probably a BCM4312 802.11 b/g device with PCI ID 14e4:4315 being us=
ed with
>>> an
>>> Atom processor in a netbook. We have no fix.
>>>
>>
>> Sorry about the missing info...
>> I asked a few times from the user, and got no reponse until today a =
few
>> hours after your response...
>>
>> It is indeed a BCM4312 802.11 b/g device with PCI ID 14e4:4315 on a =
Dell
>> laptop with a Intel ICH9M series chipset and a Intel Core(TM)2 Duo C=
PU T7250
>> @ 2.00GHz.
>
> Weird... that's not an Intel Atom, but a Core 2 Duo, standard-voltage=
=2E
> Mind posting any more details on this system?
>

It's a Dell Latitude E5500, Bios A13.

It's a 64bit kernel/userspace.

The b43 firmware is: 478.104

lspci -vvvnnn states:
  0c:00.0 Network controller [0280]: Broadcom Corporation BCM4312=20
802.11b/g [14e4:4315] (rev 01)
          Subsystem: Dell Wireless 1397 WLAN Mini-Card [1028:000c]
          Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
ParErr- Stepping- SERR+ FastB2B- DisINTx-
          Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbo=
rt-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
          Latency: 0, Cache Line Size: 64 bytes
          Interrupt: pin A routed to IRQ 17
          Region 0: Memory at f69fc000 (64-bit, non-prefetchable) [size=
=3D16K]
          Capabilities: <access denied>
          Kernel driver in use: b43-pci-bridge
          Kernel modules: wl, ssb


Anything else you need ?

--
Thomas
