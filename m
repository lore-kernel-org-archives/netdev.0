From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 02/10] staging: irda: Delete ten error messages for a failed
 memory allocation
Date: Thu, 12 Oct 2017 12:40:43 +0200
Message-ID: <7ce22c79-4b72-0e81-e5dd-fcaead712fc4@users.sourceforge.net>
References: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        David Howells <dhowells@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Georgiana Chelu <georgiana.chelu93@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Samuel Ortiz <samuel@sortiz.org>,
        Srishti Sharma <srishtishar@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Yuan Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 10 Oct 2017 21:10:43 +0200

Omit extra messages for a memory allocation failure in these functions.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/irda/net/irias_object.c | 24 ++++--------------------
 drivers/staging/irda/net/irlap_frame.c  |  4 +---
 drivers/staging/irda/net/irlmp.c        |  1 -
 drivers/staging/irda/net/irttp.c        |  1 -
 4 files changed, 5 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/irda/net/irias_object.c b/drivers/staging/irda/net/irias_object.c
index 1064fac2fd36..4db986b9d756 100644
--- a/drivers/staging/irda/net/irias_object.c
+++ b/drivers/staging/irda/net/irias_object.c
@@ -49,17 +49,12 @@ struct ias_object *irias_new_object( char *name, int id)
 	struct ias_object *obj;
 
 	obj = kzalloc(sizeof(*obj), GFP_ATOMIC);
-	if (obj == NULL) {
-		net_warn_ratelimited("%s(), Unable to allocate object!\n",
-				     __func__);
+	if (!obj)
 		return NULL;
-	}
 
 	obj->magic = IAS_OBJECT_MAGIC;
 	obj->name = kstrndup(name, IAS_MAX_CLASSNAME, GFP_ATOMIC);
 	if (!obj->name) {
-		net_warn_ratelimited("%s(), Unable to allocate name!\n",
-				     __func__);
 		kfree(obj);
 		return NULL;
 	}
@@ -319,11 +314,8 @@ void irias_add_integer_attrib(struct ias_object *obj, char *name, int value,
 	IRDA_ASSERT(name != NULL, return;);
 
 	attrib = kzalloc(sizeof(*attrib), GFP_ATOMIC);
-	if (attrib == NULL) {
-		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
-				     __func__);
+	if (!attrib)
 		return;
-	}
 
 	attrib->magic = IAS_ATTRIB_MAGIC;
 	attrib->name = kstrndup(name, IAS_MAX_ATTRIBNAME, GFP_ATOMIC);
@@ -363,11 +355,8 @@ void irias_add_octseq_attrib(struct ias_object *obj, char *name, __u8 *octets,
 	IRDA_ASSERT(octets != NULL, return;);
 
 	attrib = kzalloc(sizeof(*attrib), GFP_ATOMIC);
-	if (attrib == NULL) {
-		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
-				     __func__);
+	if (!attrib)
 		return;
-	}
 
 	attrib->magic = IAS_ATTRIB_MAGIC;
 	attrib->name = kstrndup(name, IAS_MAX_ATTRIBNAME, GFP_ATOMIC);
@@ -405,11 +394,8 @@ void irias_add_string_attrib(struct ias_object *obj, char *name, char *value,
 	IRDA_ASSERT(value != NULL, return;);
 
 	attrib = kzalloc(sizeof(*attrib), GFP_ATOMIC);
-	if (attrib == NULL) {
-		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
-				     __func__);
+	if (!attrib)
 		return;
-	}
 
 	attrib->magic = IAS_ATTRIB_MAGIC;
 	attrib->name = kstrndup(name, IAS_MAX_ATTRIBNAME, GFP_ATOMIC);
@@ -470,7 +456,6 @@ struct ias_value *irias_new_string_value(char *string)
 	value->charset = CS_ASCII;
 	value->t.string = kstrndup(string, IAS_MAX_STRING, GFP_ATOMIC);
 	if (!value->t.string) {
-		net_warn_ratelimited("%s: Unable to kmalloc!\n", __func__);
 		kfree(value);
 		return NULL;
 	}
@@ -503,7 +488,6 @@ struct ias_value *irias_new_octseq_value(__u8 *octseq , int len)
 
 	value->t.oct_seq = kmemdup(octseq, len, GFP_ATOMIC);
 	if (value->t.oct_seq == NULL){
-		net_warn_ratelimited("%s: Unable to kmalloc!\n", __func__);
 		kfree(value);
 		return NULL;
 	}
diff --git a/drivers/staging/irda/net/irlap_frame.c b/drivers/staging/irda/net/irlap_frame.c
index 21891ef7ee33..d4d88a5d2976 100644
--- a/drivers/staging/irda/net/irlap_frame.c
+++ b/drivers/staging/irda/net/irlap_frame.c
@@ -433,10 +433,8 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 	}
 
 	discovery = kzalloc(sizeof(*discovery), GFP_ATOMIC);
-	if (!discovery) {
-		net_warn_ratelimited("%s: kmalloc failed!\n", __func__);
+	if (!discovery)
 		return;
-	}
 
 	discovery->data.daddr = info->daddr;
 	discovery->data.saddr = self->saddr;
diff --git a/drivers/staging/irda/net/irlmp.c b/drivers/staging/irda/net/irlmp.c
index 38772a3b9df8..f075735e4b9b 100644
--- a/drivers/staging/irda/net/irlmp.c
+++ b/drivers/staging/irda/net/irlmp.c
@@ -641,7 +641,6 @@ struct lsap_cb *irlmp_dup(struct lsap_cb *orig, void *instance)
 	/* Allocate a new instance */
 	new = kmemdup(orig, sizeof(*new), GFP_ATOMIC);
 	if (!new)  {
-		pr_debug("%s(), unable to kmalloc\n", __func__);
 		spin_unlock_irqrestore(&irlmp->unconnected_lsaps->hb_spinlock,
 				       flags);
 		return NULL;
diff --git a/drivers/staging/irda/net/irttp.c b/drivers/staging/irda/net/irttp.c
index 958bfbe38bfb..bcab5a60cd47 100644
--- a/drivers/staging/irda/net/irttp.c
+++ b/drivers/staging/irda/net/irttp.c
@@ -1443,7 +1443,6 @@ struct tsap_cb *irttp_dup(struct tsap_cb *orig, void *instance)
 	/* Allocate a new instance */
 	new = kmemdup(orig, sizeof(*new), GFP_ATOMIC);
 	if (!new) {
-		pr_debug("%s(), unable to kmalloc\n", __func__);
 		spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);
 		return NULL;
 	}
-- 
2.14.2
