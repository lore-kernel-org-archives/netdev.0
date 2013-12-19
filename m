From: "Bob Falken" <NetFestivalHaveFun@gmx.com>
Subject: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Thu, 19 Dec 2013 15:48:16 +0100
Message-ID: <20131219144816.33310@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:57329 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810Ab3LSOsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 09:48:20 -0500
Received: from mailout-eu.gmx.com ([10.1.101.214]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0MAAjv-1VmpGV2ysr-00BLKZ for
 <netdev@vger.kernel.org>; Thu, 19 Dec 2013 15:48:18 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, I have an issue after kernel 2.6.37 and above.
If i roll back to kernel 2.6.36.4 everything is fine.
if recive more than=C2=A04294967295 multicast packets, the kernel does =
not register the multicast packets. and multicast routing does not func=
tioning.
(Tested bouth FIB_HASH and FIB_TRIE) =C2=A0=20
Tested with xorp and pimd.=20
I have abount 24 multicast groups, and it takes me=C2=A0about 17hours=C2=
=A0to reproduce the issue after a reboot.
Reboot is reqired to fix the issue. (Tested to stop/start pimd/xorp, re=
load network module for the network interface "e1000e",
Used birdge adapter and remove bridge adapter and readd bridge adapter =
to clear counters. none of thouse solves the issue.)

When the packet count for the input interface goes over 4294967295 pack=
ets.=20
br0 Link encap:Ethernet HWaddr XX:XX:XX:XX:XX:XX=20
 inet addr:10.255.255.1 Bcast:10.255.255.255 Mask:255.255.255.0=20
 UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1=20
 RX packets:4295483655 errors:0 dropped:0 overruns:0 frame:0=20
 TX packets:4210 errors:0 dropped:0 overruns:0 carrier:0=20
 collisions:0 txqueuelen:0=20
 RX bytes:3350477250900 (3.0 TiB) TX bytes:240828 (235.1 KiB)=C2=A0

"/proc/net/ip_mr_cache" goes blank.=20

This is the state of "/proc/net/ip_mr_cache" a couple of seconds before=
 the stop:=20
Group Origin Iif Pkts Bytes Wrong Oifs=20
0A0202EF 0BFFFF0A 1 181610713 4217402668 0=20
090202EF 0BFFFF0A 1 181610715 4217404228 0=20
080202EF 0BFFFF0A 1 181610716 4217405008 0=20
070202EF 0BFFFF0A 1 181610716 4217405008 0=20
180202EF 0DFFFF0A 1 181611351 4217900308 0=20
170202EF 0DFFFF0A 1 181611353 4217901868 0=20
120202EF 0CFFFF0A 1 170885816 146950304 0=20
020202EF 0AFFFF0A 1 181609636 4216562608 0=20
160202EF 0DFFFF0A 1 181611358 4217905768 0=20
150202EF 0DFFFF0A 1 181611359 4217906548 0=20
060202EF 0AFFFF0A 1 181609641 4216566508 0=20
140202EF 0DFFFF0A 1 181611364 4217910448 0=20
050202EF 0AFFFF0A 1 181609644 4216568848 0=20
130202EF 0DFFFF0A 1 181611366 4217912008 0=20
040202EF 0AFFFF0A 1 181609649 4216572748 0=20
030202EF 0AFFFF0A 1 181609651 4216574308 0 0:1=20
110202EF 0CFFFF0A 1 170885832 146962784 0=20
010202EF 0AFFFF0A 1 181609652 4216575088 0 0:1=20
100202EF 0CFFFF0A 1 170885837 146966684 0=20
0F0202EF 0CFFFF0A 1 170885838 146967464 0=20
0E0202EF 0CFFFF0A 1 170885841 146969804 0=20
0D0202EF 0CFFFF0A 1 170885842 146970584 0=20
0C0202EF 0BFFFF0A 1 181610767 4217444788 0=20
0B0202EF 0BFFFF0A 1 181610772 4217448688 0=20
i have also tested the following kernels:linux-2.6.38.8=20
linux-2.6.39.4=20
linux-3.2.53=20
linux-3.10.24=20
linux-3.11.9
I can reproduce the issue on all of them.=20

dmesg does provide any messages when this issue occure.

My arcutecture is "amd64".

I think there might be a variable in the kernel that get overflown. tho=
ugh i cannot be sure as im not a programmer.=20

Let me know if you need more debug information.

Please help.=C2=A0=20
