From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH v3 1/6] netfilter: sanity checks on NFPROTO_NUMPROTO
Date: Tue, 15 May 2012 13:32:51 +0100
Message-ID: <1337085171-1907-1-git-send-email-alban.crequy@collabora.co.uk>
References: <20120514190416.GD14897@1984>
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120514190416.GD14897@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the NFPROTO_* constants introduced by commit 7e9c6e ("netfilter: Introduce
NFPROTO_* constants"), it is too easy to confuse PF_* and NFPROTO_* constants
in new protocols.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
v2:
 - use WARN
 - return -EINVAL
v3:
 - two checkings

 net/netfilter/core.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e1b7e05..448b531 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -67,6 +67,16 @@ int nf_register_hook(struct nf_hook_ops *reg)
 	struct nf_hook_ops *elem;
 	int err;
 
+	if (reg->pf >= NFPROTO_NUMPROTO) {
+		WARN(1, "netfilter: Invalid nfproto %d\n", reg->pf);
+		return -EINVAL;
+	}
+
+	if (reg->hooknum >= NF_MAX_HOOKS) {
+		WARN(1, "netfilter: Invalid hooknum %d\n", reg->hooknum);
+		return -EINVAL;
+	}
+
 	err = mutex_lock_interruptible(&nf_hook_mutex);
 	if (err < 0)
 		return err;
-- 
1.7.2.5

