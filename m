From: Cong Wang <amwang@redhat.com>
Subject: [PATCH v3 net-next 0/4] ipv6: fix the reassembly expire code in nf_conntrack
Date: Tue, 18 Sep 2012 21:45:07 +0800
Message-ID: <1347975911-5655-1-git-send-email-amwang@redhat.com>
Cc: netfilter-devel@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51497 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757335Ab2IRNpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 09:45:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V3: rename struct netns_nf_ct to struct netns_nf_frag

V2: use IS_ENABLED(CONFIG_IPV6) to fix a build error
    rebase to latest net-next

ipv6: add a new namespace for nf_conntrack_reasm
ipv6: unify conntrack reassembly expire code with standard one
ipv6: make ip6_frag_nqueues() and ip6_frag_mem() static
ipv6: unify fragment thresh handling code

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

-----

 include/net/inet_frag.h                 |    2 +-
 include/net/ipv6.h                      |   32 +++++-
 include/net/net_namespace.h             |    3 +
 include/net/netns/ipv6.h                |    8 ++
 net/ipv4/inet_fragment.c                |    9 +-
 net/ipv4/ip_fragment.c                  |    5 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |  196 ++++++++++++++++---------------
 net/ipv6/reassembly.c                   |   88 ++++----------
 8 files changed, 178 insertions(+), 165 deletions(-)
