From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Tue, 13 Apr 2010 22:01:47 +0200
Message-ID: <1271188907.16881.563.camel@edumazet-laptop>
References: <4B9E6C60.7030300@atlanticlinux.ie>
	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>
	 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>
	 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>
	 <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop>
	 <4BC31AA0.5070006@gmail.com> <4BC31DDE.7010005@gmail.com>
	 <1271085862.16881.38.camel@edumazet-laptop> <4BC3461D.3070002@gmail.com>
	 <1271091581.16881.41.camel@edumazet-laptop> <4BC44167.4080807@gmail.com>
	 <1271155766.16881.245.camel@edumazet-laptop> <4BC44EC8.1010104@gmail.com>
	 <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>
	 <4BC47F38.5040509@gmail.com> <1271169741.16881.437.camel@edumazet-laptop>
	 <4BC48460.4040001@gmail.com> <1271171107.16881.465.camel@edumazet-laptop>
	 <4BC488DA.3020508@gmail.com> <1271172172.16881.484.camel@edumazet-laptop>
	 <4BC48CE0.1080504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: stephen mulcahy <smulcahy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:64385 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021Ab0DMUBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 16:01:55 -0400
Received: by bwz19 with SMTP id 19so1294bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 13:01:53 -0700 (PDT)
In-Reply-To: <4BC48CE0.1080504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 16:25 +0100, stephen mulcahy a =C3=A9crit=
 :
> Eric Dumazet wrote:
> > OK, thanks for clarification.
> >=20
> > Last question, did you tried a vanilla kernel, aka 2.6.33.2 for
> > example ?
>=20
> I built a Debian package from the vanilla 2.6.33.2 and installed that=
 on=20
> all nodes and tried my reproducer with the same results - nodes becom=
ing=20
> unresponsive.
>=20
> I didn't try changing the tso and tx settings with the 2.6.33.2 kerne=
l=20
> though. Let me know if that would be useful (and/or if there is anoth=
er=20
> kernel that you would like me to test with) and I'll try to fit it in=
=2E
>=20

I tried 2.6.34-rc4 (64bits) on an old machine I had lying at home.



00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)
	Subsystem: ASUSTeK Computer Inc. K8N4-E or A8N-E Mainboard
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx+
	Latency: 0 (250ns min, 5000ns max)
	Interrupt: pin A routed to IRQ 21
	Region 0: Memory at d4000000 (32-bit, non-prefetchable) [size=3D4K]
	Region 1: I/O ports at b000 [size=3D8]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D=
3cold+)
		Status: D0 NoSoftRst- PME-Enable+ DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: forcedeth
	Kernel modules: forcedeth

I could not reproduce the problem you have.

processor	: 0
vendor_id	: AuthenticAMD
cpu family	: 15
model		: 31
model name	: AMD Athlon(tm) 64 Processor 3200+
stepping	: 0
cpu MHz		: 1000.000
cache size	: 512 KB
fpu		: yes
fpu_exception	: yes
cpuid level	: 1
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov =
pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext fxsr_opt lm 3dnow=
ext 3dnow rep_good lahf_lm
bogomips	: 2010.09
TLB size	: 1024 4K pages
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management: ts fid vid ttp


RAM : 3 Gbytes=20

Only strange thing I noticed is ethtool -S results with an insane tx_br=
oadcast

# ethtool -S eth1
NIC statistics:
     tx_bytes: 90388
     tx_zero_rexmt: 348
     tx_one_rexmt: 0
     tx_many_rexmt: 0
     tx_late_collision: 0
     tx_fifo_errors: 0
     tx_carrier_errors: 0
     tx_excess_deferral: 0
     tx_retry_error: 0
     rx_frame_error: 0
     rx_extra_byte: 0
     rx_late_collision: 0
     rx_runt: 0
     rx_frame_too_long: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_align_error: 0
     rx_length_error: 0
     rx_unicast: 413
     rx_multicast: 22
     rx_broadcast: 2
     rx_packets: 437
     rx_errors_total: 0
     tx_errors_total: 0
     tx_deferral: 718
     tx_packets: 718
     rx_bytes: 718
     tx_pause: 718
     rx_pause: 718
     rx_drop_frame: 718
     tx_unicast: 15748
     tx_multicast: 5552
     tx_broadcast: 115174309658

[root@localhost ~]# ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:11:D8:9A:6D:06 =20
          inet adr:192.168.99.99  Bcast:192.168.99.255  Masque:255.255.=
255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:466 errors:0 dropped:0 overruns:0 frame:0
          TX packets:354 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 lg file transmission:1000=20
          RX bytes:50751 (49.5 KiB)  TX bytes:92974 (90.7 KiB)
          Interruption:21 Adresse de base:0x2000=20

[root@localhost ~]# grep eth1 /proc/interrupts=20
 21:        954   IO-APIC-fasteoi   eth1


