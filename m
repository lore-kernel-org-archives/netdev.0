From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 0/1] Add support of ECMPv6
Date: Wed, 19 Sep 2012 11:18:23 +0200
Message-ID: <1348046304-4156-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1347609548-14494-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: bernat@luffy.cx, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:51227 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516Ab2ISJQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 05:16:26 -0400
In-Reply-To: <1347609548-14494-1-git-send-email-nicolas.dichtel@6wind.com>
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

Comments are welcome.

Regards,
Nicolas
