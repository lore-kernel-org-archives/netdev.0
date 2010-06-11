From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Weak host model vs .interface down
Date: Fri, 11 Jun 2010 14:24:21 +0200
Message-ID: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:33985 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753305Ab0FKM0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 08:26:48 -0400
Received: from sesr04.transmode.se (sesr04.transmode.se [192.168.201.15])
	by gw1.transmode.se (Postfix) with ESMTP id 5330365000A
	for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 14:26:46 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Linux uses the weak host model which makes the IP addresses part of the system
rather than the interface. However consider this:

System A, eth0 connected to the network
# > ifconfig eth0 192.168.1.16
# > ifconfig eth1 192.168.1.17 down

System B
# > ping 192.168.1.17
PING 192.168.1.17 (192.168.1.17) 56(84) bytes of data.
64 bytes from 192.168.1.17: icmp_seq=1 ttl=64 time=0.618 ms

Isn't it a bit much to respond on 192.168.1.17 when its interface is down?
I even tried to set rp_filter=1 for all interfaces and that didn't help
either(not that I should need to)

   Jocke

