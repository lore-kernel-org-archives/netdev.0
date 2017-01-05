From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter fixes for net
Date: Thu,  5 Jan 2017 12:19:47 +0100
Message-ID: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49646 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759518AbdAELUH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 06:20:07 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 2DED25230B
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:03 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1F6FF9EBD5
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:03 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6AD59DA878
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:19:59 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains accumulated Netfilter fixes for your
net tree:

1) Ensure quota dump and reset happens iff we can deliver numbers to
   userspace.

2) Silence splat on incorrect use of smp_processor_id() from nft_queue.

3) Fix an out-of-bound access reported by KASAN in
   nf_tables_rule_destroy(), patch from Florian Westphal.

4) Fix layer 4 checksum mangling in the nf_tables payload expression
   with IPv6.

5) Fix a race in the CLUSTERIP target from control plane path when two
   threads run to add a new configuration object. Serialize invocations
   of clusterip_config_init() using spin_lock. From Xin Long.

6) Call br_nf_pre_routing_finish_bridge_finish() once we are done with
   the br_nf_pre_routing_finish() hook. From Artur Molchanov.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Wish you a nice new year btw, thanks!

----------------------------------------------------------------

The following changes since commit a220871be66f99d8957c693cf22ec67ecbd9c23a:

  virtio-net: correctly enable multiqueue (2016-12-13 10:37:38 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 14221cc45caad2fcab3a8543234bb7eda9b540d5:

  bridge: netfilter: Fix dropping packets that moving through bridge interface (2016-12-30 18:22:50 +0100)

----------------------------------------------------------------
Artur Molchanov (1):
      bridge: netfilter: Fix dropping packets that moving through bridge interface

Florian Westphal (1):
      netfilter: nf_tables: fix oob access

Pablo Neira Ayuso (3):
      netfilter: nft_quota: reset quota after dump
      netfilter: nft_queue: use raw_smp_processor_id()
      netfilter: nft_payload: mangle ckecksum if NFT_PAYLOAD_L4CSUM_PSEUDOHDR is set

Xin Long (1):
      netfilter: ipt_CLUSTERIP: check duplicate config when initializing

 net/bridge/br_netfilter_hooks.c    |  2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c | 34 +++++++++++++++++++++++-----------
 net/netfilter/nf_tables_api.c      |  2 +-
 net/netfilter/nft_payload.c        | 27 +++++++++++++++++++--------
 net/netfilter/nft_queue.c          |  2 +-
 net/netfilter/nft_quota.c          | 26 ++++++++++++++------------
 6 files changed, 59 insertions(+), 34 deletions(-)
