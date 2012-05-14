From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 1/6] netfilter: sanity checks on NFPROTO_NUMPROTO
Date: Mon, 14 May 2012 14:56:34 +0100
Message-ID: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:48679 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756101Ab2ENN4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 09:56:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the NFPROTO_* constants introduced by commit 7e9c6e ("netfilter: Introduce
NFPROTO_* constants"), it is too easy to confuse PF_* and NFPROTO_* constants
in new protocols.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 net/netfilter/core.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e1b7e05..4f16552 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -67,6 +67,11 @@ int nf_register_hook(struct nf_hook_ops *reg)
 	struct nf_hook_ops *elem;
 	int err;
 
+	if (reg->pf >= NFPROTO_NUMPROTO || reg->hooknum >= NF_MAX_HOOKS) {
+		BUG();
+		return 1;
+	}
+
 	err = mutex_lock_interruptible(&nf_hook_mutex);
 	if (err < 0)
 		return err;
-- 
1.7.2.5
