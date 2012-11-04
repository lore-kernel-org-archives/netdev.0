From: Hiroyuki Yamada <mogwaing@gmail.com>
Subject: some nodes in a cluster has higher frame value in ifconfig
Date: Sun, 4 Nov 2012 16:37:23 +0900
Message-ID: <CAPDOW74k6krw1qCB-rTPbuUr3zLp7TNcfM9+UDB6Rmf_YkqXRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:56758 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190Ab2KDHhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 02:37:24 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so4933340vcb.19
        for <netdev@vger.kernel.org>; Sun, 04 Nov 2012 00:37:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am running a cluster consisting of 22 nodes.
(22 nodes under the same 1Gbps switch.)
I noticed some nodes in the cluster has higher "frame" value in
ifconfig like the following.

some nodes (higher frame):
eth0      Link encap:Ethernet  HWaddr 90:B1:1C:09:D2:F8
          inet addr:192.168.121.20  Bcast:192.168.121.255  Mask:255.255.255.0
          inet6 addr: fe80::92b1:1cff:fe09:d2f8/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:643150667 errors:0 dropped:790 overruns:0 frame:280072
          TX packets:908361364 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:377424658828 (351.5 GiB)  TX bytes:864099883266 (804.7 GiB)
          Interrupt:170 Memory:d91a0000-d91b0000

other nodes (lower frame):
eth0      Link encap:Ethernet  HWaddr 24:B6:FD:F6:DF:34
          inet addr:192.168.121.3  Bcast:192.168.121.255  Mask:255.255.255.0
          inet6 addr: fe80::26b6:fdff:fef6:df34/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1126524649 errors:0 dropped:118 overruns:0 frame:43775
          TX packets:847071691 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:992080311726 (923.9 GiB)  TX bytes:385366462299 (358.9 GiB)
          Interrupt:170 Memory:d91a0000-d91b0000

What might be wrong with it ?
I also ran ethtool and
"rxbds_empty" value is the same value as frame in ifconfig.
whta is rxbds_empty ?
I have investigated rxbds_empty, but there is almost no information about it.

The weird thing is newly added 6 nodes have that higher value.
Also, I noticed some program runs slower than before we added those 6 nodes.
What the program is doing is that
every node requests huge amount of short messages
to other random nodes in parallel.
Ideally, every node has the some completion time with the program,
but the added 6 nodes run slower than others.

Could anyone give me any advice ?
