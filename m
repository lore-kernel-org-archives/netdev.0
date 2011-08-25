From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: iwlagn: Random "Time out reading EEPROM".
Date: Thu, 25 Aug 2011 15:50:43 +0200
Message-ID: <4E565333.3080007@gmail.com>
References: <4DEA2FC1.2030104@gmail.com>	 <1307284276.6918.17.camel@wwguy-ubuntu>  <4E1FF8B8.9020005@gmail.com> <1310740111.13897.13.camel@wwguy-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "dhalperi-GmWTxIRN22iJaUV4rX00uodd74u8MsAO@public.gmane.org" <dhalperi-GmWTxIRN22iJaUV4rX00uodd74u8MsAO@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: wwguy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1310740111.13897.13.camel@wwguy-ubuntu>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 15/07/2011 16:28, wwguy a =C3=A9crit :

> the error indicate fail to read data from EEPROM, your 2nd report is
> even more strange, the number at the end the error message indicate t=
he
> index of DWORD driver trying to read from EEPROM.
>
> "Time out reading EEPROM[2]" telling me the first 2 DWORD is reading =
ok
> but not the 3rd read.
>
> How many PCI-E slots you have in your system, could it possible for y=
ou
> to switch to another PCI-E slot, or pull out and re-insert the NIC.

Unfortunately, not. On this laptop, the NIC is not reachable without di=
sassembling the laptop, and I=20
don't want to... I will double check again, but...

> Also, it is possible to put the NIC into different system and see if =
you
> are seeing the similar problem?

No, for the exact same reason.

Not that it still happens with 3.0.0-1 from Debian.

[   15.086244] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux=
, in-tree:
[   15.086247] iwlagn: Copyright(c) 2003-2011 Intel Corporation
[   15.086404] iwlagn 0000:05:00.0: PCI INT A -> GSI 18 (level, low) ->=
 IRQ 18
[   15.086412] iwlagn 0000:05:00.0: setting latency timer to 64
[   15.086438] iwlagn 0000:05:00.0: Detected Intel(R) WiFi Link 5100 AG=
N, REV=3D0x54
[   15.095859] iwlagn 0000:05:00.0: Time out reading EEPROM[6]
[   15.095945] iwlagn 0000:05:00.0: Unable to init EEPROM
[   15.096030] iwlagn 0000:05:00.0: PCI INT A disabled
[   15.096039] iwlagn: probe of 0000:05:00.0 failed with error -110

modprobe -r iwlagn ; modprobe iwlagn

[  231.822492] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux=
, in-tree:
[  231.822495] iwlagn: Copyright(c) 2003-2011 Intel Corporation
[  231.822581] iwlagn 0000:05:00.0: PCI INT A -> GSI 18 (level, low) ->=
 IRQ 18
[  231.822591] iwlagn 0000:05:00.0: setting latency timer to 64
[  231.822621] iwlagn 0000:05:00.0: Detected Intel(R) WiFi Link 5100 AG=
N, REV=3D0x54
[  231.843544] iwlagn 0000:05:00.0: device EEPROM VER=3D0x11f, CALIB=3D=
0x4
[  231.843546] iwlagn 0000:05:00.0: Device SKU: 0Xb
[  231.844889] iwlagn 0000:05:00.0: Tunable channels: 13 802.11bg, 24 8=
02.11a channels
[  231.844961] iwlagn 0000:05:00.0: irq 50 for MSI/MSI-X
[  231.989424] iwlagn 0000:05:00.0: loaded firmware version 8.83.5.1 bu=
ild 33692
[  232.037456] ieee80211 phy0: Selected rate control algorithm 'iwl-agn=
-rs'

The error is not easy to reproduce, but the fix is perfectly stable. A =
single unload/reload of=20
iwlagn is always enough to solve the problem, when it happens. For this=
 reason, it sounds difficult=20
to consider this a hardware slot problem. Can't this be related to some=
 other PCI components?

00:00.0 Host bridge: Intel Corporation Mobile 4 Series Chipset Memory C=
ontroller Hub (rev 07)
00:01.0 PCI bridge: Intel Corporation Mobile 4 Series Chipset PCI Expre=
ss Graphics Port (rev 07)
00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #4 (rev 03)
00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #5 (rev 03)
00:1a.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #6 (rev 03)
00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHC=
I Controller #2 (rev 03)
00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio C=
ontroller (rev 03)
00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express =
Port 1 (rev 03)
00:1c.1 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express =
Port 2 (rev 03)
00:1c.2 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express =
Port 3 (rev 03)
00:1c.3 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express =
Port 4 (rev 03)
00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express =
Port 5 (rev 03)
00:1c.5 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express =
Port 6 (rev 03)
00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #1 (rev 03)
00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #2 (rev 03)
00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #3 (rev 03)
00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHC=
I Controller #1 (rev 03)
00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev 93)
00:1f.0 ISA bridge: Intel Corporation ICH9M LPC Interface Controller (r=
ev 03)
00:1f.2 SATA controller: Intel Corporation ICH9M/M-E SATA AHCI Controll=
er (rev 03)
00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller =
(rev 03)
01:00.0 VGA compatible controller: nVidia Corporation G98 [GeForce 9300=
M GS] (rev a1)
02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8055 PCI-=
E Gigabit Ethernet Controller=20
(rev 14)
05:00.0 Network controller: Intel Corporation WiFi Link 5100
09:03.0 FireWire (IEEE 1394): Ricoh Co Ltd R5C832 IEEE 1394 Controller =
(rev 05)
09:03.1 SD Host controller: Ricoh Co Ltd R5C822 SD/SDIO/MMC/MS/MSPro Ho=
st Adapter (rev 22)
09:03.2 System peripheral: Ricoh Co Ltd R5C592 Memory Stick Bus Host Ad=
apter (rev 12)

I'm quite sure I can fix this problem by loading, unloading and reloadi=
ng iwlagn on every startup...=20
but I don't really consider this a fix :-/

	Nicolas.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
