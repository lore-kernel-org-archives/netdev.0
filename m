From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3 nf-next] nf_tables support at ingress
Date: Mon, 25 May 2015 14:46:39 +0200
Message-ID: <1432558004-13481-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56547 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622AbbEYMlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 08:41:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is the follow-up patchset to add nf_tables on top of the Netfilter ingress
hook [1] now available in the net-next tree:

1) default CONFIG_NETFILTER_INGRESS to y for easier compile-testing of all
   options.

2) Allow to bind a table to net_device. This introduces the internal
   NFT_AF_NEEDS_DEV flag to perform a mandatory check for this binding.
   This patch is required by the next patch.

3) Add the 'netdev' table family, this new table allows you to create ingress
   filter basechains. This provides access to the existing nf_tables features
   from ingress.

After this, I'll prepare more patches to revisit our existing limit expression
and to add support for the tee expression.

If no objections, I'll enqueue this patchset to the nf-next tree.

Thanks.

[1] https://lwn.net/Articles/644937/

Pablo Neira Ayuso (3):
  netfilter: default CONFIG_NETFILTER_INGRESS to y
  netfilter: nf_tables: allow to bind table to net_device
  netfilter: nf_tables: add netdev table to filter from ingress

 include/net/netfilter/nf_tables.h        |    8 ++
 include/net/netns/nftables.h             |    1 +
 include/uapi/linux/netfilter/nf_tables.h |    2 +
 net/netfilter/Kconfig                    |    6 +
 net/netfilter/Makefile                   |    1 +
 net/netfilter/nf_tables_api.c            |   46 +++++++-
 net/netfilter/nf_tables_netdev.c         |  183 ++++++++++++++++++++++++++++++
 7 files changed, 242 insertions(+), 5 deletions(-)
 create mode 100644 net/netfilter/nf_tables_netdev.c

-- 
1.7.10.4
