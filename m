From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/10] Netfilter/IPVS updates for net-next
Date: Tue,  8 Mar 2016 11:00:40 +0100
Message-ID: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40364 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932071AbcCHKBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 05:01:05 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C4EC8842C
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:02 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B3CC9CE171
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:02 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 210B1CE171
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:00:58 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for your net-next tree,
they are:

1) Remove useless debug message when deleting IPVS service, from
   Yannick Brosseau.

2) Get rid of compilation warning when CONFIG_PROC_FS is unset in
   several spots of the IPVS code, from Arnd Bergmann.

3) Add prandom_u32 support to nft_meta, from Florian Westphal.

4) Remove unused variable in xt_osf, from Sudip Mukherjee.

5) Don't calculate IP checksum twice from netfilter ipv4 defrag hook
   since fixing af_packet defragmentation issues, from Joe Stringer.

6) On-demand hook registration for iptables from netns. Instead of
   registering the hooks for every available netns whenever we need
   one of the support tables, we register this on the specific netns
   that needs it, patchset from Florian Westphal.

7) Add missing port range selection to nf_tables masquerading support.

BTW, just for the record, there is a typo in the description of
5f6c253ebe93b0 ("netfilter: bridge: register hooks only when bridge
interface is added") that refers to the cluster match as deprecated, but
it is actually the CLUSTERIP target (which registers hooks
inconditionally) the one that is scheduled for removal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit f12d33f4d83c6837d176e1aef337914089c77957:

  3c59x: Ensure to apply the expires time (2016-02-28 23:39:26 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 8a6bf5da1aefdafd60b73d9122c7af9fd2d7bb9c:

  netfilter: nft_masq: support port range (2016-03-02 20:05:27 +0100)

----------------------------------------------------------------
Arnd Bergmann (1):
      netfilter: ipvs: avoid unused variable warnings

Florian Westphal (5):
      netfilter: meta: add PRANDOM support
      netfilter: xtables: prepare for on-demand hook register
      netfilter: xtables: don't hook tables by default
      netfilter: bridge: register hooks only when bridge interface is added
      netfilter: don't call hooks unless needed

Joe Stringer (1):
      netfilter: nf_defrag_ipv4: Drop redundant ip_send_check()

Pablo Neira Ayuso (2):
      Merge tag 'ipvs-for-v4.6' of https://git.kernel.org/.../horms/ipvs-next into HEAD
      netfilter: nft_masq: support port range

Sudip Mukherjee (1):
      netfilter: xt_osf: remove unused variable

Yannick Brosseau (1):
      netfilter: ipvs: Remove noisy debug print from ip_vs_del_service

 include/linux/netfilter.h                 | 29 +++++--------
 include/linux/netfilter/x_tables.h        |  6 ++-
 include/linux/netfilter_arp/arp_tables.h  |  9 ++--
 include/linux/netfilter_ipv4/ip_tables.h  |  9 ++--
 include/linux/netfilter_ipv6/ip6_tables.h |  9 ++--
 include/net/netfilter/nft_masq.h          |  4 +-
 include/uapi/linux/netfilter/nf_tables.h  |  6 +++
 lib/random32.c                            |  1 +
 net/bridge/br_netfilter_hooks.c           | 68 +++++++++++++++++++++++++++++--
 net/ipv4/netfilter/arp_tables.c           | 66 ++++++++++++++++++------------
 net/ipv4/netfilter/arptable_filter.c      | 40 ++++++++++--------
 net/ipv4/netfilter/ip_tables.c            | 63 ++++++++++++++++------------
 net/ipv4/netfilter/iptable_filter.c       | 44 +++++++++++++-------
 net/ipv4/netfilter/iptable_mangle.c       | 41 +++++++++++++------
 net/ipv4/netfilter/iptable_nat.c          | 41 ++++++++++---------
 net/ipv4/netfilter/iptable_raw.c          | 38 +++++++++++------
 net/ipv4/netfilter/iptable_security.c     | 44 ++++++++++++--------
 net/ipv4/netfilter/nf_defrag_ipv4.c       |  4 +-
 net/ipv4/netfilter/nft_masq_ipv4.c        |  7 +++-
 net/ipv6/netfilter/ip6_tables.c           | 65 +++++++++++++++++------------
 net/ipv6/netfilter/ip6table_filter.c      | 47 +++++++++++++--------
 net/ipv6/netfilter/ip6table_mangle.c      | 46 +++++++++++++--------
 net/ipv6/netfilter/ip6table_nat.c         | 41 ++++++++++---------
 net/ipv6/netfilter/ip6table_raw.c         | 46 +++++++++++++--------
 net/ipv6/netfilter/ip6table_security.c    | 44 ++++++++++++--------
 net/ipv6/netfilter/nft_masq_ipv6.c        |  7 +++-
 net/netfilter/ipvs/ip_vs_app.c            |  8 +---
 net/netfilter/ipvs/ip_vs_ctl.c            | 17 +++-----
 net/netfilter/nft_masq.c                  | 51 ++++++++++++++++++-----
 net/netfilter/nft_meta.c                  | 11 +++++
 net/netfilter/x_tables.c                  | 65 +++++++++++++++++------------
 net/netfilter/xt_osf.c                    |  2 -
 32 files changed, 626 insertions(+), 353 deletions(-)
