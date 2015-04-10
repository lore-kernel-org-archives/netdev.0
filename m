From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Fri, 10 Apr 2015 14:15:35 +0200
Message-ID: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset adds the Netfilter hook at the ingress path, in a per-device
fashion. This also comes with the new nf_tables 'netdev' family support to
provide access to users to the existing nf_tables features. This includes the
transactional netlink API and the enhanced set infrastructure.  Several patches
come in first place to prepare this support, including the refactoring of
__netif_receive_skb_core() to accomodate the new hook.

As in other netfilter hooks, a static key is used to disable the hook path when
no hooks are registered, so the ingress path remains similar to what we already
have. The static key that governs this is global.

The netfilter ingress hook comes just after handle_ing() to honor the existing
qdisc ingress infrastructure.

You can find a simple example ruleset file to account traffic at:

	http://people.netfilter.org/pablo/nft-ingress.ruleset

Comments are welcome, thanks.

Pablo Neira Ayuso (7):
  net: refactor __netif_receive_skb_core
  netfilter: add nf_hook_list_active()
  netfilter: add hook list to nf_hook_state
  netfilter: cleanup struct nf_hook_ops struct indentation
  net: add netfilter ingress hook
  netfilter: nf_tables: allow to bind table to net_device
  netfilter: nf_tables: add netdev table to filter from ingress

 include/linux/netdevice.h		  |    4 +-
 include/linux/netfilter.h		  |   39 +++---
 include/linux/netfilter_ingress.h	  |   80 +++++++++++++
 include/net/netfilter/nf_tables.h	  |    8 ++
 include/net/netns/nftables.h		  |    1 +
 include/uapi/linux/netfilter.h		  |    6 +
 include/uapi/linux/netfilter/nf_tables.h |    2 +
 net/core/dev.c				  |  190 +++++++++++++++++++-----------
 net/netfilter/Kconfig			  |    6 +
 net/netfilter/Makefile			  |    1 +
 net/netfilter/core.c			  |   28 ++++-
 net/netfilter/nf_tables_api.c		  |   47 +++++++-
 net/netfilter/nf_tables_netdev.c	  |  182 ++++++++++++++++++++++++++++
 13 files changed, 502 insertions(+), 92 deletions(-)
 create mode 100644 include/linux/netfilter_ingress.h
 create mode 100644 net/netfilter/nf_tables_netdev.c

--
1.7.10.4

