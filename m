From: john stultz <johnstul@us.ibm.com>
Subject: Re: 2.6.30-rc3, forcedeth: no net
Date: Fri, 6 Jan 2012 19:12:23 -0800
Message-ID: <CANcMJZCVeC8FS0hptZ3+_Wu7E9vMqxoQOZ5ejVivJ1diiXh1NA@mail.gmail.com>
References: <49F2D0B1.6030800@t-online.de>
	<20090428202259.ede11021.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Harald Dunkel <harald.dunkel@t-online.de>,
	Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:43246 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759048Ab2AGDMY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 22:12:24 -0500
In-Reply-To: <20090428202259.ede11021.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2009 at 8:22 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> (cc's added)
> On Sat, 25 Apr 2009 10:58:25 +0200 Harald Dunkel <harald.dunkel@t-onl=
ine.de> wrote:
>
>> There is a problem with forcedeth: The initialization on my
>> machine takes several minutes. This exceeds the usual wait
>> loop of dhcpcd. Using a static IP address doesn't help, either.
>> IP address and so on are set correctly, but there is still
>> no net.
>>
>> I could reproduce this with 2.6.29.1 and 2.6.30-rc3. For
>> testing I had reverted cb52deba12f27af90a46d2f8667a64888118a888
>> ("power down phy when interface is down"), but this did not help.
>> It was a wild guess, anyway.
>>
>> /var/log/messages:
>> :
>> :
>> Apr 25 10:29:53 elmer kernel: [ =A0 =A05.796093] forcedeth: Reverse =
Engineered nForce ethernet driver. Version 0.64.
>> Apr 25 10:29:53 elmer kernel: [ =A0 =A05.908812] ACPI: PCI Interrupt=
 Link [LMAC] enabled at IRQ 22
>> Apr 25 10:29:53 elmer kernel: [ =A0 =A05.944151] forcedeth 0000:00:0=
a.0: PCI INT A -> Link[LMAC] -> GSI 22 (level, low) -> IRQ 22
>> Apr 25 10:29:53 elmer kernel: [ =A0 =A06.056607] forcedeth 0000:00:0=
a.0: ifname eth0, PHY OUI 0x732 @ 1, addr 00:22:68:62:c1:8d
>> Apr 25 10:29:53 elmer kernel: [ =A0 =A06.075176] usbcore: registered=
 new interface driver usbfs
>> Apr 25 10:29:53 elmer kernel: [ =A0 =A06.154910] forcedeth 0000:00:0=
a.0: highdma csum pwrctl gbit lnktim msi desc-v3
>> :
>> :
>> Apr 25 10:29:54 elmer kernel: [ =A0 22.422017] eth0: no link during =
initialization.
>> Apr 25 10:29:54 elmer kernel: [ =A0 24.774868] eth0: link up.
>> Apr 25 10:29:54 elmer kernel: [ =A0 24.780817] eth0: link down.
>> Apr 25 10:29:54 elmer kernel: [ =A0 31.401174] eth0: link up.
>> Apr 25 10:29:54 elmer kernel: [ =A0 33.169139] eth0: link down.
>> Apr 25 10:29:54 elmer kernel: [ =A0 38.006407] eth0: link up.
>> Apr 25 10:29:54 elmer kernel: [ =A0 38.011970] eth0: link down.
>> Apr 25 10:31:58 elmer kernel: [ =A0216.027643] eth0: link up.
>> :
>>
>> lspci:
>> 00:0a.0 Ethernet controller: nVidia Corporation MCP79 Ethernet (rev =
b1)
>> =A0 =A0 =A0 =A0 Subsystem: Acer Incorporated [ALI] Device 0222
>> =A0 =A0 =A0 =A0 Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VG=
ASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>> =A0 =A0 =A0 =A0 Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Df=
ast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>> =A0 =A0 =A0 =A0 Latency: 0 (250ns min, 5000ns max)
>> =A0 =A0 =A0 =A0 Interrupt: pin A routed to IRQ 22
>> =A0 =A0 =A0 =A0 Region 0: Memory at fae7d000 (32-bit, non-prefetchab=
le) [size=3D4K]
>> =A0 =A0 =A0 =A0 Region 1: I/O ports at d080 [size=3D8]
>> =A0 =A0 =A0 =A0 Region 2: Memory at fae7e800 (32-bit, non-prefetchab=
le) [size=3D256]
>> =A0 =A0 =A0 =A0 Region 3: Memory at fae7e400 (32-bit, non-prefetchab=
le) [size=3D16]
>> =A0 =A0 =A0 =A0 Capabilities: [44] Power Management version 2
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Flags: PMEClk- DSI- D1+ D2+ AuxCurre=
nt=3D0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Status: D0 PME-Enable+ DSel=3D0 DSca=
le=3D0 PME-
>> =A0 =A0 =A0 =A0 Kernel driver in use: forcedeth
>>
>> The machine is an Acer Aspire Revo.
>>

Just FYI, I burned the day chasing a very similar issue on an Acer
Aspire Revo (R1600).  After being a fine test machine for a few years,
all of a sudden the link would seem to go down when booting custom
kernels.  Running. ifconfig eth0 down; ifconfig eth0 up would fix it,
as would unplugging and re-plugging in the cable.  Once it got into
this state, changing kernel versions wouldn't matter. No link at
bootup.

The only odd bit was the distro kernel (Ubuntu 11.10 3.0.0 based)
would usually work (although not always). I suspect this has to do
with some sort of timing issue, as the distro kernel uses modules and
my kernels are statically linked.

In the past, this had happened once before, and disconnecting the
power to the system for a bit, and then reconnecting it seemed to
resolve it. Unfortunately that didn't work this time.

Anyway, after trying numerous kernels and config changes trying to
narrow things down, I ended up flashing the BIOS (from P01-A1 to
P01-A4L_A) and the issue went away.

Anyway, googling on this shows tons of similar strange behavior with
forcedeth, so I wanted to post what worked for me.  And while it may
just be some old BIOS/firmware bug, the odd behavior between distro
kernels and my own makes me suspect there's some sort of timing race
with the current driver when the network adapter gets into this
strange state.

thanks
-john
