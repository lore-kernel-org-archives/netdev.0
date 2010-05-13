From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 13/20] net/caif: Use kzalloc
Date: Thu, 13 May 2010 22:03:32 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005132203150.6282@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use kzalloc rather than the combination of kmalloc and memset.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression x,size,flags;
statement S;
@@

-x = kmalloc(size,flags);
+x = kzalloc(size,flags);
 if (x == NULL) S
-memset(x, 0, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/caif/cfcnfg.c |    3 +--
 net/caif/cfctrl.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff -u -p a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -65,12 +65,11 @@ struct cfcnfg *cfcnfg_create(void)
 	struct cfcnfg *this;
 	struct cfctrl_rsp *resp;
 	/* Initiate this layer */
-	this = kmalloc(sizeof(struct cfcnfg), GFP_ATOMIC);
+	this = kzalloc(sizeof(struct cfcnfg), GFP_ATOMIC);
 	if (!this) {
 		pr_warning("CAIF: %s(): Out of memory\n", __func__);
 		return NULL;
 	}
-	memset(this, 0, sizeof(struct cfcnfg));
 	this->mux = cfmuxl_create();
 	if (!this->mux)
 		goto out_of_mem;
diff -u -p a/net/caif/cfctrl.c b/net/caif/cfctrl.c
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -284,12 +284,11 @@ int cfctrl_linkup_request(struct cflayer
 			   __func__, param->linktype);
 		return -EINVAL;
 	}
-	req = kmalloc(sizeof(*req), GFP_KERNEL);
+	req = kzalloc(sizeof(*req), GFP_KERNEL);
 	if (!req) {
 		pr_warning("CAIF: %s(): Out of memory\n", __func__);
 		return -ENOMEM;
 	}
-	memset(req, 0, sizeof(*req));
 	req->client_layer = user_layer;
 	req->cmd = CFCTRL_CMD_LINK_SETUP;
 	req->param = *param;
