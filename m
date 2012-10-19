From: nicolas.dichtel@6wind.com
Subject: [PATCH net-next v7 0/1] Add support of ECMPv6
Date: Fri, 19 Oct 2012 11:13:25 +0200
Message-ID: <1350638006-4213-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1349194467.12401.810.camel@edumazet-glaptop>
Cc: joe@perches.com, bernat@luffy.cx, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56797 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757927Ab2JSJFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 05:05:49 -0400
In-Reply-To: <1349194467.12401.810.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a proposal to add the support of ECMPv6. The previous patch
from Vincent against iproute2 can be used, but a little other patch is needed
too, see http://patchwork.ozlabs.org/patch/183277/
He also starts to write a patch against quagga, to be able to manage ECMPv6
routes implemented in this patch:
http://marc.info/?l=quagga-dev&m=135040310117116&w=2

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

v7: fix checkpatch.pl warning
    invert rt6i_nsiblings and rt6i_siblings in struct rt6_info

v6: be more verbose in commitlog
    add some helpers in ip6_fib.h to avoid to have too many ifdef block in the
    code
    invert fc_mp_len and fc_mp in struct fib6_config to avoid a hole on 64bits
    arch

v5: to minimize the patch and ease its integration, remove roundrobin and random
    algorithms for route selection. It will be possible to add new algorithms
    through rt6_info_hashfn() when the basic support of ECMP is integrated.

v4: remove compilation options to choose multipath algorithm for next hop
    selection. Now the choice can be done at run time via
    /proc/sys/net/ipv6/route/multipath_algorithm

v3: rebase after updating net-next

v2: rename CONFIG_IPV6_MULTIPATH_ROUTE to CONFIG_IPV6_MULTIPATH_HASH
    use flowlabel in the hash function
    add reference to RFC
    fix a small identation issue
    remove "If unsure, say N." from the help of CONFIG_IPV6_MULTIPATH

Comments are welcome.

Regards,
Nicolas
