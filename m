From: Tim Durack <tdurack@gmail.com>
Subject: r8169 MAC problem
Date: Fri, 6 Mar 2009 14:29:13 -0500
Message-ID: <9e246b4d0903061129g7b66dc3bm8013b75be671ca33@mail.gmail.com>
References: <9e246b4d0903061127q7c82103dq88c5184765f3c17a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:50199 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776AbZCFT3Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 14:29:16 -0500
In-Reply-To: <9e246b4d0903061127q7c82103dq88c5184765f3c17a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like the r8169 MAC bug is still lurking:

CFG-1:~# uname -a
Linux CFG-1 2.6.29-rc7-686 #1 SMP Fri Mar 6 01:07:38 UTC 2009 i686 GNU/=
Linux

CFG-1:~# modprobe -r r8169
[=A0 198.684076] r8169 0000:00:0c.0: PCI INT A disabled
[=A0 198.944075] r8169 0000:00:0b.0: PCI INT A disabled
[=A0 199.204080] r8169 0000:00:09.0: PCI INT A disabled

CFG-1:~# modprobe -i r8169
[=A0 202.183521] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[=A0 202.189230] r8169 0000:00:09.0: PCI INT A -> GSI 18 (level, low) -=
> IRQ 18
[=A0 202.197440] r8169 0000:00:09.0: no PCI Express capability
[=A0 202.203116] r8169 0000:00:09.0: MAC address found in EEPROM:
00:30:18:ab:f0:34
[=A0 202.212721] eth0: RTL8169sc/8110sc at 0xf90b0000,
00:00:00:00:f0:34, XID 18000000 IRQ 18
[=A0 202.221555] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[=A0 202.227202] r8169 0000:00:0b.0: PCI INT A -> GSI 19 (level, low) -=
> IRQ 19
[=A0 202.234202] r8169 0000:00:0b.0: no PCI Express capability
[=A0 202.239859] r8169 0000:00:0b.0: MAC address found in EEPROM:
00:30:18:ab:f0:35
[=A0 202.249413] eth1: RTL8169sc/8110sc at 0xf8012000,
00:00:00:00:f0:35, XID 18000000 IRQ 19
[=A0 202.258267] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[=A0 202.263911] r8169 0000:00:0c.0: PCI INT A -> GSI 16 (level, low) -=
> IRQ 16
[=A0 202.270890] r8169 0000:00:0c.0: no PCI Express capability
[=A0 202.276551] r8169 0000:00:0c.0: MAC address found in EEPROM:
00:30:18:ab:f0:36
[=A0 202.286256] eth2: RTL8169sc/8110sc at 0xf8016000,
00:30:18:ab:f0:36, XID 18000000 IRQ 16

This obviously doesn't work very well. Full power-cycle back into
2.6.26 fixes the problem:

CFG-1:~# uname -a
Linux CFG-1 2.6.26-1-686 #1 SMP Sun Feb 8 02:27:05 UTC 2009 i686 GNU/Li=
nux

CFG-1:~# modprobe -r r8169
[=A0=A0 83.220122] ACPI: PCI interrupt for device 0000:00:0c.0 disabled
[=A0=A0 83.252673] ACPI: PCI interrupt for device 0000:00:0b.0 disabled
[=A0=A0 83.285249] ACPI: PCI interrupt for device 0000:00:09.0 disabled

CFG-1:~# modprobe -i r8169
[=A0=A0 87.454505] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[=A0=A0 87.461284] ACPI: PCI Interrupt 0000:00:09.0[A] ->=A0 a future
releasGSI 18 (level, low) -> IRQ 18
[=A0=A0 87.476007] eth0: RTL8169sc/8110sc at 0xf8832000,
00:30:18:ab:f0:34, XID 18000000 IRQ 18
[=A0=A0 87.484682] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[=A0=A0 87.489660] ACPI: PCI Interrupt 0000:00:0b.0[A] -> GSI 19 (level=
,
low) -> IRQ 19
[=A0=A0 87.500006] eth1: RTL8169sc/8110sc at 0xf8834000,
00:30:18:ab:f0:35, XID 18000000 IRQ 19
[=A0=A0 87.508675] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[=A0=A0 87.513633] ACPI: PCI Interrupt 0000:00:0c.0[A] -> GSI 16 (level=
,
low) -> IRQ 16
[=A0=A0 87.524006] eth2: RTL8169sc/8110sc at 0xf8f88000,
00:30:18:ab:f0:36, XID 18000000 IRQ 16

Based on googling around, I'm going to guess this might be related:

Ivan Vecera (1): r8169: read MAC address from EEPROM on init (2nd attem=
pt)

Any ideas?

Tim:>
