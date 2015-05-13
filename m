From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net 0/2] IPv6 ECMP route add/replace fixes
Date: Wed, 13 May 2015 11:50:30 +0200 (CEST)
Message-ID: <cover.1431500953.git.mkubecek@suse.cz>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(1) When adding a nexthop of a multipath route fails (e.g. because of a
conflict with an existing route), we are supposed to delete nexthops
already added. However, currently we try to also delete all nexthops we
haven't even tried to add yet so that a "ip route add" command can
actually remove pre-existing routes if it fails.

(2) Attempt to replace a multipath route results in a broken siblings
linked list. Following commands (like "ip route del") can then either
follow a link into freed memory or end in an infinite loop (if the slab
object has been reused).

Michal Kubecek (2):
  ipv6: do not delete previously existing ECMP routes if add fails
  ipv6: fix ECMP route replacement

 net/ipv6/ip6_fib.c | 17 ++++++++++++++---
 net/ipv6/route.c   |  9 ++++++---
 2 files changed, 20 insertions(+), 6 deletions(-)

-- 
2.3.7
