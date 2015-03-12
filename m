From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 nf-next 0/6] more bridge netfilter refactoring
Date: Thu, 12 Mar 2015 18:05:19 +0100
Message-ID: <1426179925-18220-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is another batch towards the planned skb->nf_bridge removal.

These patches rid ip_fragment of the bridge netfilter mtu/ll hacks
and remove the nf_bridge_info->data area that is used to store
original mac address for refragmentation and neigh resolution.

The need to use it for the DNAT detection is already resolved
via

http://patchwork.ozlabs.org/patch/448342/

These patches go on top of this.

While at it, this series also replaces the 'mask' flags with
a tristate enum to separate those 'flags' that have to be visible
outside of bridge netfilter context and those that are internal.

Tested, on host connected to kvm-bridge:

ping -s $bignum $ip_behind_bridge

on bridge:
-j REDIRECT
-j DNAT --to-destination $ip_behind_bridge

 include/linux/netfilter_bridge.h          |   36 ----
 include/linux/skbuff.h                    |   16 +
 include/net/ip.h                          |    4 
 net/bridge/br_device.c                    |    2 
 net/bridge/br_netfilter.c                 |  246 +++++++++++++++++++++---------
 net/bridge/br_private.h                   |    2 
 net/ipv4/ip_output.c                      |   37 ++--
 net/ipv4/netfilter/nf_defrag_ipv4.c       |    2 
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c |    2 
 9 files changed, 215 insertions(+), 132 deletions(-)
