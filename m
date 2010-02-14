From: =?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: linux-2..6.33-rc7 and b43
Date: Sun, 14 Feb 2010 22:53:22 +0100
Message-ID: <69e28c911002141353x7805033fl2e68ae56f3dabf40@mail.gmail.com>
References: <4B77C819.9050602@mandriva.org> <4B782670.9080001@lwfinger.net>
	<4B784498.8030509@mandriva.org> <69e28c911002141059y57fb2097x5613c25ad1c616da@mail.gmail.com>
	<4B784C68.8020402@mandriva.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thomas Backlund <tmb-4qZELD6Fgxhg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B784C68.8020402-4qZELD6Fgxhg9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2010/2/14 Thomas Backlund <tmb-4qZELD6Fgxhg9hUCZPvPmw@public.gmane.org>:
> G=E1bor Stefanik skrev 14.2.2010 20:59:
>>
>> On Sun, Feb 14, 2010 at 7:44 PM, Thomas Backlund<tmb-4qZELD6Fgxhg9hUCZPvPmw@public.gmane.org> =A0=
wrote:
>>>
>>> Larry Finger skrev 14.2.2010 18:36:
>>>>
>>>> On 02/14/2010 03:53 AM, Thomas Backlund wrote:
>>>>>
>>>>> Hi,
>>>>> (please cc me on replies)
>>>>>
>>>>> We have a user that tried out b43, but got this in the logs:
>>>>>
>>>>> --- cut ---
>>>>> 65858:Feb =A09 22:05:16 elmo kernel: b43-phy2 ERROR: This device =
does not
>>>>> support DMA on your system. Please use PIO instead. 65859:Feb =A0=
9
>>>>> 22:05:16 elmo kernel: b43-phy2 ERROR: CONFIG_B43_FORCE_PIO must
>>>>> be set in your kernel configuration.
>>>>> 65860:Feb =A09 22:05:16 elmo kernel: b43-phy2 debug: Adding Inter=
face
>>>>> type
>>>>> 2
>>>>> 65861:Feb =A09 22:05:16 elmo kernel: b43-phy2 ERROR: Fatal DMA er=
ror:
>>>>> 0x00000400, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x000=
00000
>>>>>
>>>>> 65862:Feb =A09 22:05:16 elmo kernel: b43-phy2 ERROR: This device =
does not
>>>>> support DMA on your system. Please use PIO instead.
>>>>> 65863:Feb =A09 22:05:16 elmo kernel: b43-phy2 ERROR: CONFIG_B43_F=
ORCE_PIO
>>>>> must be set in your kernel configuration.
>>>>> --- cut ---
>>>>>
>>>>>
>>>>>
>>>>> But reading the Kconfig help, it states:
>>>>> --- cut ---
>>>>> config B43_FORCE_PIO
>>>>> =A0 =A0 =A0 =A0 bool "Force usage of PIO instead of DMA"
>>>>> =A0 =A0 =A0 =A0 depends on B43&& =A0 =A0B43_DEBUG
>>>>> =A0 =A0 =A0 =A0 ---help---
>>>>> =A0 =A0 =A0 =A0 =A0 This will disable DMA and always enable PIO i=
nstead.
>>>>>
>>>>> =A0 =A0 =A0 =A0 =A0 Say N!
>>>>> =A0 =A0 =A0 =A0 =A0 This is only for debugging the PIO engine cod=
e. You do
>>>>> =A0 =A0 =A0 =A0 =A0 _NOT_ want to enable this.
>>>>> --- cut ---
>>>>>
>>>>>
>>>>> So,
>>>>> wich one is it ?
>>>>>
>>>>> Do I belive the dmesg output, or the Kconfig ?
>>>>>
>>>>> Note,
>>>>> the b43 works for the user if he enable the CONFIG_B43_FORCE_PIO.
>>>>>
>>>>> But I'm thinking of this problem from a distro point of view.
>>>>> Will it break for others if I enable it ?
>>>>
>>>>> =A0From a distro point of view, you would not want to set FORCE_P=
IO as
>>>>> the
>>>>
>>>> performance penalty would be very large.
>>>>
>>>
>>> As I suspected.
>>> Thanks for confirming it.
>>>
>>>> You do not give the specific details on the problem system; howeve=
r, it
>>>> is
>>>> probably a BCM4312 802.11 b/g device with PCI ID 14e4:4315 being u=
sed
>>>> with
>>>> an
>>>> Atom processor in a netbook. We have no fix.
>>>>
>>>
>>> Sorry about the missing info...
>>> I asked a few times from the user, and got no reponse until today a=
 few
>>> hours after your response...
>>>
>>> It is indeed a BCM4312 802.11 b/g device with PCI ID 14e4:4315 on a=
 Dell
>>> laptop with a Intel ICH9M series chipset and a Intel Core(TM)2 Duo =
CPU
>>> T7250
>>> @ 2.00GHz.
>>
>> Weird... that's not an Intel Atom, but a Core 2 Duo, standard-voltag=
e.
>> Mind posting any more details on this system?
>>
>
> It's a Dell Latitude E5500, Bios A13.
>
> It's a 64bit kernel/userspace.
>
> The b43 firmware is: 478.104
>
> lspci -vvvnnn states:
> =A00c:00.0 Network controller [0280]: Broadcom Corporation BCM4312 80=
2.11b/g
> [14e4:4315] (rev 01)
> =A0 =A0 =A0 =A0 Subsystem: Dell Wireless 1397 WLAN Mini-Card [1028:00=
0c]
> =A0 =A0 =A0 =A0 Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGA=
Snoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
> =A0 =A0 =A0 =A0 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0 Latency: 0, Cache Line Size: 64 bytes
> =A0 =A0 =A0 =A0 Interrupt: pin A routed to IRQ 17
> =A0 =A0 =A0 =A0 Region 0: Memory at f69fc000 (64-bit, non-prefetchabl=
e) [size=3D16K]
> =A0 =A0 =A0 =A0 Capabilities: <access denied>
> =A0 =A0 =A0 =A0 Kernel driver in use: b43-pci-bridge
> =A0 =A0 =A0 =A0 Kernel modules: wl, ssb
>
>
> Anything else you need ?
>
> --
> Thomas
>

Looks like the trigger is not Intel Atom, but PhoenixBIOS after all -
a quick analysis of bios v. A15 for this machine shows it to be a
highly cloaked/rebranded PhoenixBIOS.

Core 2 T7250 is a regular Merom/Santa Rosa CPU, almost the same as my
T7100 (only the clock multiplier is different), and is not a ULV CPU,
the trigger we previously suspected.

PhoenixBIOS (and its rebrands) appears to be the common trigger.

--=20
Vista: [V]iruses, [I]ntruders, [S]pyware, [T]rojans and [A]dware. :-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
