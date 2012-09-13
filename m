From: pablo@netfilter.org
Subject: [PATCH 0/5] Netfilter updates for net-next
Date: Thu, 13 Sep 2012 13:01:27 +0200
Message-ID: <1347534092-3579-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains four Netfilter updates, mostly targeting
to fix issues added with IPv6 NAT, and one little IPVS update for net-next:

* Remove unneeded conditional free of skb in nfnetlink_queue, from
  Wei Yongjun.

* One semantic path from coccinelle detected the use of list_del +
  INIT_LIST_HEAD, instead of list_del_init, again from Wei Yongjun.

* Fix out-of-bound memory access in the NAT address selection, from
  Florian Westphal. This was introduced with the IPv6 NAT patches.

* Two fixes for crashes that were introduced in the recently merged
  IPv6 NAT support, from myself.

You can pull these changes from:

git://1984.lsi.us.es/nf-next master

Thanks!

Florian Westphal (1):
  netfilter: nf_nat: fix out-of-bounds access in address selection

Pablo Neira Ayuso (2):
  netfilter: fix crash during boot if NAT has been compiled built-in
  netfilter: ctnetlink: fix module auto-load in ctnetlink_parse_nat

Wei Yongjun (2):
  netfilter: nfnetlink_queue: remove pointless conditional before kfree_skb()
  ipvs: use list_del_init instead of list_del/INIT_LIST_HEAD

 net/netfilter/Makefile               |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c       |    3 +--
 net/netfilter/nf_conntrack_netlink.c |    3 ---
 net/netfilter/nf_nat_core.c          |    2 +-
 net/netfilter/nfnetlink_queue_core.c |    3 +--
 5 files changed, 4 insertions(+), 9 deletions(-)

-- 
1.7.10.4

