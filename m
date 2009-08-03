From: "durgam@it.iitb.ac.in phani" <durgam.iit@gmail.com>
Subject: reg IFF_RUNNING behaviour
Date: Mon, 3 Aug 2009 14:56:29 +0530
Message-ID: <f46324890908030226g1702f3a1t88bbef25a0c331fa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:57219 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012AbZHCJ02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 05:26:28 -0400
Received: by gxk9 with SMTP id 9so5656365gxk.13
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 02:26:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when the  interface operational status goes down (IFF_RUNNING)  why
linux ip stack is not  flushing routing/neighbour (arp) entries
related to the interface . I  have the following doubt .

If  there are two routes to the destiantion,   one route is more
specific and  points to the eth0 and another one points to the another
interface eth1.   If eth0 goes down operationally ,   linux kernel has
not removed the specific route which points eth0.  When the traffic
came for this destination,  specific route was getting exercised and
traffic was getting dropped . Why is this behaviour supported in
linux.


This is exampe.

eth0   Link encap:Ethernet  HWaddr 00:05:1E:76:42:A1
          inet addr:4.4.4.2  Bcast:4.4.4.255  Mask:255.255.255.0
          UP BROADCAST MULTICAST  MTU:9018  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:5 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0

eth1     Link encap:Ethernet  HWaddr 00:05:1E:76:42:80
          inet addr:10.32.152.16  Bcast:10.32.159.255  Mask:255.255.240.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:115582 errors:1 dropped:0 overruns:0 frame:0
          TX packets:1472 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000


Routing table

Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.2.2.52       0.0.0.0         255.255.255.255 UH    0      0        0  eth0
4.4.4.0         0.0.0.0         255.255.255.0   U     0      0        0  eth0
10.32.144.0     0.0.0.0         255.255.240.0   U     0      0        0 eth1
0.0.0.0         10.32.144.1     0.0.0.0         UG    0      0        0 eth1



Thanks
Pani.
