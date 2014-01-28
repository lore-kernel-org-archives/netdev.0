From: Asi Lichtenstein <asili22@gmail.com>
Subject: IPv6 multiple routing tables - all routes were added to main table
Date: Tue, 28 Jan 2014 11:38:11 +0200
Message-ID: <CAMBtn_0S0K6eydjTLJAsVqbKVuJ+tc7k30OUWRxscm+gP6y2EQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:56587 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754836AbaA1JiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 04:38:11 -0500
Received: by mail-ob0-f177.google.com with SMTP id wp18so133336obc.36
        for <netdev@vger.kernel.org>; Tue, 28 Jan 2014 01:38:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I'm using an old kernel 2.6.16 where i applied this patchset:
http://thread.gmane.org/gmane.linux.network/41149/focus=41150

i was able to create new table but all routes I've added to specific
table were added to main table.

please see output:

# ip -6 rule
0:      from all vrf 0 lookup local
16383:  from all iif eth0 vrf 0 lookup 3
16383:  from all iif eth1 vrf 0 lookup 5
32766:  from all vrf 0 lookup main

# ip -6 route show
2050:: dev eth0  proto static  metric 10  expires 2132979sec mtu 1500
advmss 1440 metric10 4294967295
2050:: dev eth1  proto static  metric 10  expires 2132996sec mtu 1500
advmss 1440 metric10 4294967295
unreachable default dev lo  proto none  metric -1  error -128 metric10 255
unreachable default dev lo  proto none  metric -1  error -128 metric10 255
unreachable default dev lo  proto none  metric -1  error -128 metric10 255
2000::/64 dev eth0.1  metric 256  expires 2132967sec mtu 1500 advmss
1440 metric10 4294967295
2000::/64 dev eth0  metric 256  expires 2132978sec mtu 1500 advmss
1440 metric10 4294967295
fe80::/64 dev eth0  metric 256  expires 2132960sec mtu 1500 advmss
1440 metric10 4294967295
fe80::/64 dev eth1  metric 256  expires 2132960sec mtu 1500 advmss
1440 metric10 4294967295
fe80::/64 dev eth0.4001  metric 256  expires 2132960sec mtu 1500
advmss 1440 metric10 4294967295
fe80::/64 dev eth0.1  metric 256  expires 2132961sec mtu 1500 advmss
1440 metric10 4294967295
unreachable default dev lo  proto none  metric -1  error -128 metric10 255
ff00::/8 dev eth1  metric 256  expires 2132960sec mtu 1500 advmss 1440
metric10 4294967295
ff00::/8 dev eth0.4001  metric 256  expires 2132960sec mtu 1500 advmss
1440 metric10 4294967295
ff00::/8 dev eth0  metric 256  expires 2132960sec mtu 1500 advmss 1440
metric10 4294967295
ff00::/8 dev eth0.1  metric 256  expires 2132961sec mtu 1500 advmss
1440 metric10 4294967295
unreachable default dev lo  proto none  metric -1  error -128 metric10 255


Does anyone know if adding route to specific table should be working
after applying this patch?

10x
