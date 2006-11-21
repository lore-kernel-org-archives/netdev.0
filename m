From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 6/11] [IRDA]: Use kmemdup where applicable
Date: Tue, 21 Nov 2006 01:28:20 -0200
Message-ID: <20061121032819.GG7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:11757 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030595AbWKUD20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:28:26 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/irda/iriap.c        |    3 +--
 net/irda/irias_object.c |    4 +---
 net/irda/irlmp.c        |    4 +---
 net/irda/irqueue.c      |    3 +--
 4 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index ab86d70..8cfd076 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -172,7 +172,7 @@ struct iriap_cb *iriap_open(__u8 slsap_s
 
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
 
-	self = kmalloc(sizeof(struct iriap_cb), GFP_ATOMIC);
+	self = kzalloc(sizeof(*self), GFP_ATOMIC);
 	if (!self) {
 		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
 		return NULL;
@@ -181,7 +181,6 @@ struct iriap_cb *iriap_open(__u8 slsap_s
 	/*
 	 *  Initialize instance
 	 */
-	memset(self, 0, sizeof(struct iriap_cb));
 
 	self->magic = IAS_MAGIC;
 	self->mode = mode;
diff --git a/net/irda/irias_object.c b/net/irda/irias_object.c
index 56292ab..b1ee99a 100644
--- a/net/irda/irias_object.c
+++ b/net/irda/irias_object.c
@@ -501,13 +501,12 @@ struct ias_value *irias_new_octseq_value
 		len = IAS_MAX_OCTET_STRING;
 	value->len = len;
 
-	value->t.oct_seq = kmalloc(len, GFP_ATOMIC);
+	value->t.oct_seq = kmemdup(octseq, len, GFP_ATOMIC);
 	if (value->t.oct_seq == NULL){
 		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
 		kfree(value);
 		return NULL;
 	}
-	memcpy(value->t.oct_seq, octseq , len);
 	return value;
 }
 
@@ -522,7 +521,6 @@ struct ias_value *irias_new_missing_valu
 	}
 
 	value->type = IAS_MISSING;
-	value->len = 0;
 
 	return value;
 }
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 5073261..0599ac1 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -641,15 +641,13 @@ struct lsap_cb *irlmp_dup(struct lsap_cb
 	}
 
 	/* Allocate a new instance */
-	new = kmalloc(sizeof(struct lsap_cb), GFP_ATOMIC);
+	new = kmemdup(orig, sizeof(*new), GFP_ATOMIC);
 	if (!new)  {
 		IRDA_DEBUG(0, "%s(), unable to kmalloc\n", __FUNCTION__);
 		spin_unlock_irqrestore(&irlmp->unconnected_lsaps->hb_spinlock,
 				       flags);
 		return NULL;
 	}
-	/* Dup */
-	memcpy(new, orig, sizeof(struct lsap_cb));
 	/* new->lap = orig->lap; => done in the memcpy() */
 	/* new->slsap_sel = orig->slsap_sel; => done in the memcpy() */
 	new->conn_skb = NULL;
diff --git a/net/irda/irqueue.c b/net/irda/irqueue.c
index 1ba8c71..1d26cd3 100644
--- a/net/irda/irqueue.c
+++ b/net/irda/irqueue.c
@@ -356,14 +356,13 @@ hashbin_t *hashbin_new(int type)
 	/*
 	 * Allocate new hashbin
 	 */
-	hashbin = kmalloc( sizeof(hashbin_t), GFP_ATOMIC);
+	hashbin = kzalloc(sizeof(*hashbin), GFP_ATOMIC);
 	if (!hashbin)
 		return NULL;
 
 	/*
 	 * Initialize structure
 	 */
-	memset(hashbin, 0, sizeof(hashbin_t));
 	hashbin->hb_type = type;
 	hashbin->magic = HB_MAGIC;
 	//hashbin->hb_current = NULL;
-- 
1.4.2.1.g3d5c

