From: Krzysztof Oledzki <olel@ans.pl>
Subject: 64bit counters: iproute(netlink) vs ifconfig
Date: Wed, 13 Feb 2008 21:20:59 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802132114110.16999@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-103267785-1202934059=:16999"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:56785 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756414AbYBMUVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 15:21:15 -0500
Received: from bizon.gios.gov.pl (olel@localhost6 [IPv6:::1])
	by bizon.gios.gov.pl (8.14.1/8.14.1) with ESMTP id m1DKKxMU024587
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 21:21:05 +0100
Received: from localhost (olel@localhost)
	by bizon.gios.gov.pl (8.14.1/8.14.1/Submit) with ESMTP id m1DKKxAE024584
	for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 21:20:59 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-103267785-1202934059=:16999
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hello,

Just discovered that counters returned by the "ip" tool are truncated:

# ip -s link show bond0
1: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue
     link/ether 00:1d:09:67:6e:2f brd ff:ff:ff:ff:ff:ff
     RX: bytes  packets  errors  dropped overrun mcast
     2485605521 9010211  0       0       0       6
     TX: bytes  packets  errors  dropped carrier collsns
     3023237974 9345397  0       0       0       0

# ifconfig bond0
bond0     Link encap:Ethernet  HWaddr 00:1D:09:67:6E:2F
           inet addr:192.168.152.62  Bcast:192.168.152.255  Mask:255.255.25=
5.0
           inet6 addr: fe80::21d:9ff:fe67:6e2f/64 Scope:Link
           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
           RX packets:9010367 errors:0 dropped:351 overruns:0 frame:0
           TX packets:9345521 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:2485631020 (2370.4 Mb)  TX bytes:7318232294 (6979.2 Mb)

Is it possible to get 64-bit counters in ip via netlink? Struct=20
rtnl_link_stats does not look very optimistic, as it has rx_bytes/tx_bytes=
=20
defined with __u32.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-103267785-1202934059=:16999--
