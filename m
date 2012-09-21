From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v4 0/1] Add support of ECMPv6
Date: Fri, 21 Sep 2012 11:59:04 +0200
Message-ID: <1348221545-14747-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20120920.171525.2005584636029506440.davem@davemloft.net>
Cc: bernat@luffy.cx, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54261 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932972Ab2IUJ54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 05:57:56 -0400
In-Reply-To: <20120920.171525.2005584636029506440.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a proposal to add the support of ECMPv6. The previous patch
from Vincent against iproute2 can be used, but a little other patch is needed
too, see http://patchwork.ozlabs.org/patch/183277/

If the kernel patch is approved, I can submit formally the patch for
iproute2.

Here is an example of a command to add an ECMP route:
$ ip -6 route add 3ffe:304:124:2306::/64 \
	nexthop via fe80::230:1bff:feb4:e05c dev eth0 \
	nexthop via fe80::230:1bff:feb4:dd4f dev eth0

But note that this command is a shortcut and previous patches are not
mandatory to set ECMP routes. The following commands can be used too:
$ ip -6 route add 3ffe:304:124:2306::/64 via fe80::230:1bff:feb4:dd4f dev
eth0
$ ip -6 route append 3ffe:304:124:2306::/64 via fe80::230:1bff:feb4:e05c dev
eth0

Here is an example of a dump:
$ ip -6 route | grep 3ffe:304:124:2306::/64
3ffe:304:124:2306::/64 via fe80::230:1bff:feb4:dd4f dev eth0  metric 1024
3ffe:304:124:2306::/64 via fe80::230:1bff:feb4:e05c dev eth0  metric 1024

v2: rename CONFIG_IPV6_MULTIPATH_ROUTE to CONFIG_IPV6_MULTIPATH_HASH
    use flowlabel in the hash function
    add reference to RFC
    fix a small identation issue
    remove "If unsure, say N." from the help of CONFIG_IPV6_MULTIPATH

v3: rebase after updating net-next

v4: remove compilation options to choose multipath algorithm for next hop
    selection. Now the choice can be done at run time via
    /proc/sys/net/ipv6/route/multipath_algorithm

Comments are welcome.

Regards,
Nicolas
