From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IFGROUPv3 0/*] Interface groups, round 3
Date: Fri, 19 Oct 2007 18:29:58 +0200
Message-ID: <20071019-181844-1192810724.panther__41703.8160645918$1192811432$gmane$org@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:53288 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752345AbXJSQaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 12:30:08 -0400
Message-Id: <20071019-181844-1192810724.panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This is the 3rd version of interface group patches.

Each net_device structure has a non-negative ifgroup member indicating
the group it belongs to. In the ip tool it is between 0 and 256 where
0 means it is unset.

Usage:
   ip link set eth0 group 4
   ip lonk set eth0 group 0        # to unset
   ip link set eth0 group intra    # named groups

In /etc/iproute2/rt_ifgroup each value may have a symbolic name.

Netfilter part: xt_ifgroup module for both IPv4 and IPv6. Iptables usage:
   iptables -A INPUT -m ifgroup --in-ifgroup 4/0xf -j ACCEPT
   iptables -A FORWARD -m ifgroup --in-ifgroup 4 --out-ifgroup 5 -j ACCEPT
   ...

in the FORWARD chain both input and output interface group value should be matched
(with optional masks).

The following patches are:
  kernel: single notification, atomic changes
  kernel: core part
  kernel: netfilter module, ifgroup match
  iproute2: showing and set ifgroup value
  iptables: ifgroup match
--
Attila
