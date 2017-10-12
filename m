From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 01/10] staging: irda: Improve a size determination in 20
 functions
Date: Thu, 12 Oct 2017 12:39:35 +0200
Message-ID: <3a4b9a1e-71fa-4d61-0a4e-4e732e1c9a99@users.sourceforge.net>
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
Date: Tue, 10 Oct 2017 19:35:56 +0200

* Replace the specification of data types by pointer dereferences
  as the parameter for the operator "sizeof" to make the corresponding size
  determination a bit safer according to the Linux coding style convention.

  This issue was detected by using the Coccinelle software.

* The script "checkpatch.pl" pointed information out like the following.

  ERROR: do not use assignment in if condition

  Thus fix the affected source code place.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/irda/net/ircomm/ircomm_core.c |  2 +-
 drivers/staging/irda/net/ircomm/ircomm_tty.c  |  2 +-
 drivers/staging/irda/net/irias_object.c       | 16 ++++++++--------
 drivers/staging/irda/net/irlap.c              |  2 +-
 drivers/staging/irda/net/irlap_frame.c        |  7 ++++---
 drivers/staging/irda/net/irlmp.c              |  8 ++++----
 drivers/staging/irda/net/irttp.c              |  4 ++--
 7 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/irda/net/ircomm/ircomm_core.c b/drivers/staging/irda/net/ircomm/ircomm_core.c
index 3af219545f6d..6c02fbf380bd 100644
--- a/drivers/staging/irda/net/ircomm/ircomm_core.c
+++ b/drivers/staging/irda/net/ircomm/ircomm_core.c
@@ -114,7 +114,7 @@ struct ircomm_cb *ircomm_open(notify_t *notify, __u8 service_type, int line)
 
 	IRDA_ASSERT(ircomm != NULL, return NULL;);
 
-	self = kzalloc(sizeof(struct ircomm_cb), GFP_KERNEL);
+	self = kzalloc(sizeof(*self), GFP_KERNEL);
 	if (self == NULL)
 		return NULL;
 
diff --git a/drivers/staging/irda/net/ircomm/ircomm_tty.c b/drivers/staging/irda/net/ircomm/ircomm_tty.c
index ec157c3419b5..d1beec413fa3 100644
--- a/drivers/staging/irda/net/ircomm/ircomm_tty.c
+++ b/drivers/staging/irda/net/ircomm/ircomm_tty.c
@@ -380,7 +380,7 @@ static int ircomm_tty_install(struct tty_driver *driver, struct tty_struct *tty)
 	self = hashbin_lock_find(ircomm_tty, line, NULL);
 	if (!self) {
 		/* No, so make new instance */
-		self = kzalloc(sizeof(struct ircomm_tty_cb), GFP_KERNEL);
+		self = kzalloc(sizeof(*self), GFP_KERNEL);
 		if (self == NULL)
 			return -ENOMEM;
 
diff --git a/drivers/staging/irda/net/irias_object.c b/drivers/staging/irda/net/irias_object.c
index 53b86d0e1630..1064fac2fd36 100644
--- a/drivers/staging/irda/net/irias_object.c
+++ b/drivers/staging/irda/net/irias_object.c
@@ -48,7 +48,7 @@ struct ias_object *irias_new_object( char *name, int id)
 {
 	struct ias_object *obj;
 
-	obj = kzalloc(sizeof(struct ias_object), GFP_ATOMIC);
+	obj = kzalloc(sizeof(*obj), GFP_ATOMIC);
 	if (obj == NULL) {
 		net_warn_ratelimited("%s(), Unable to allocate object!\n",
 				     __func__);
@@ -318,7 +318,7 @@ void irias_add_integer_attrib(struct ias_object *obj, char *name, int value,
 	IRDA_ASSERT(obj->magic == IAS_OBJECT_MAGIC, return;);
 	IRDA_ASSERT(name != NULL, return;);
 
-	attrib = kzalloc(sizeof(struct ias_attrib), GFP_ATOMIC);
+	attrib = kzalloc(sizeof(*attrib), GFP_ATOMIC);
 	if (attrib == NULL) {
 		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
 				     __func__);
@@ -362,7 +362,7 @@ void irias_add_octseq_attrib(struct ias_object *obj, char *name, __u8 *octets,
 	IRDA_ASSERT(name != NULL, return;);
 	IRDA_ASSERT(octets != NULL, return;);
 
-	attrib = kzalloc(sizeof(struct ias_attrib), GFP_ATOMIC);
+	attrib = kzalloc(sizeof(*attrib), GFP_ATOMIC);
 	if (attrib == NULL) {
 		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
 				     __func__);
@@ -404,7 +404,7 @@ void irias_add_string_attrib(struct ias_object *obj, char *name, char *value,
 	IRDA_ASSERT(name != NULL, return;);
 	IRDA_ASSERT(value != NULL, return;);
 
-	attrib = kzalloc(sizeof( struct ias_attrib), GFP_ATOMIC);
+	attrib = kzalloc(sizeof(*attrib), GFP_ATOMIC);
 	if (attrib == NULL) {
 		net_warn_ratelimited("%s: Unable to allocate attribute!\n",
 				     __func__);
@@ -439,7 +439,7 @@ struct ias_value *irias_new_integer_value(int integer)
 {
 	struct ias_value *value;
 
-	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
+	value = kzalloc(sizeof(*value), GFP_ATOMIC);
 	if (value == NULL)
 		return NULL;
 
@@ -462,7 +462,7 @@ struct ias_value *irias_new_string_value(char *string)
 {
 	struct ias_value *value;
 
-	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
+	value = kzalloc(sizeof(*value), GFP_ATOMIC);
 	if (value == NULL)
 		return NULL;
 
@@ -491,7 +491,7 @@ struct ias_value *irias_new_octseq_value(__u8 *octseq , int len)
 {
 	struct ias_value *value;
 
-	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
+	value = kzalloc(sizeof(*value), GFP_ATOMIC);
 	if (value == NULL)
 		return NULL;
 
@@ -514,7 +514,7 @@ struct ias_value *irias_new_missing_value(void)
 {
 	struct ias_value *value;
 
-	value = kzalloc(sizeof(struct ias_value), GFP_ATOMIC);
+	value = kzalloc(sizeof(*value), GFP_ATOMIC);
 	if (value == NULL)
 		return NULL;
 
diff --git a/drivers/staging/irda/net/irlap.c b/drivers/staging/irda/net/irlap.c
index 1cde711bcab5..5dea721f44ac 100644
--- a/drivers/staging/irda/net/irlap.c
+++ b/drivers/staging/irda/net/irlap.c
@@ -110,7 +110,7 @@ struct irlap_cb *irlap_open(struct net_device *dev, struct qos_info *qos,
 	struct irlap_cb *self;
 
 	/* Initialize the irlap structure. */
-	self = kzalloc(sizeof(struct irlap_cb), GFP_KERNEL);
+	self = kzalloc(sizeof(*self), GFP_KERNEL);
 	if (self == NULL)
 		return NULL;
 
diff --git a/drivers/staging/irda/net/irlap_frame.c b/drivers/staging/irda/net/irlap_frame.c
index debda3de4726..21891ef7ee33 100644
--- a/drivers/staging/irda/net/irlap_frame.c
+++ b/drivers/staging/irda/net/irlap_frame.c
@@ -432,7 +432,8 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 		return;
 	}
 
-	if ((discovery = kzalloc(sizeof(discovery_t), GFP_ATOMIC)) == NULL) {
+	discovery = kzalloc(sizeof(*discovery), GFP_ATOMIC);
+	if (!discovery) {
 		net_warn_ratelimited("%s: kmalloc failed!\n", __func__);
 		return;
 	}
@@ -539,7 +540,7 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 		/*
 		 *  We now have some discovery info to deliver!
 		 */
-		discovery = kzalloc(sizeof(discovery_t), GFP_ATOMIC);
+		discovery = kzalloc(sizeof(*discovery), GFP_ATOMIC);
 		if (!discovery)
 			return;
 
@@ -1201,7 +1202,7 @@ void irlap_send_test_frame(struct irlap_cb *self, __u8 caddr, __u32 daddr,
 
 	/* Broadcast frames must include saddr and daddr fields */
 	if (caddr == CBROADCAST) {
-		frame = skb_put(tx_skb, sizeof(struct test_frame));
+		frame = skb_put(tx_skb, sizeof(*frame));
 
 		/* Insert the swapped addresses */
 		frame->saddr = cpu_to_le32(self->saddr);
diff --git a/drivers/staging/irda/net/irlmp.c b/drivers/staging/irda/net/irlmp.c
index 43964594aa12..38772a3b9df8 100644
--- a/drivers/staging/irda/net/irlmp.c
+++ b/drivers/staging/irda/net/irlmp.c
@@ -168,7 +168,7 @@ struct lsap_cb *irlmp_open_lsap(__u8 slsap_sel, notify_t *notify, __u8 pid)
 		return NULL;
 
 	/* Allocate new instance of a LSAP connection */
-	self = kzalloc(sizeof(struct lsap_cb), GFP_ATOMIC);
+	self = kzalloc(sizeof(*self), GFP_ATOMIC);
 	if (self == NULL)
 		return NULL;
 
@@ -290,7 +290,7 @@ void irlmp_register_link(struct irlap_cb *irlap, __u32 saddr, notify_t *notify)
 	/*
 	 *  Allocate new instance of a LSAP connection
 	 */
-	lap = kzalloc(sizeof(struct lap_cb), GFP_KERNEL);
+	lap = kzalloc(sizeof(*lap), GFP_KERNEL);
 	if (lap == NULL)
 		return;
 
@@ -1466,7 +1466,7 @@ void *irlmp_register_service(__u16 hints)
 	pr_debug("%s(), hints = %04x\n", __func__, hints);
 
 	/* Make a new registration */
-	service = kmalloc(sizeof(irlmp_service_t), GFP_ATOMIC);
+	service = kmalloc(sizeof(*service), GFP_ATOMIC);
 	if (!service)
 		return NULL;
 
@@ -1538,7 +1538,7 @@ void *irlmp_register_client(__u16 hint_mask, DISCOVERY_CALLBACK1 disco_clb,
 	IRDA_ASSERT(irlmp != NULL, return NULL;);
 
 	/* Make a new registration */
-	client = kmalloc(sizeof(irlmp_client_t), GFP_ATOMIC);
+	client = kmalloc(sizeof(*client), GFP_ATOMIC);
 	if (!client)
 		return NULL;
 
diff --git a/drivers/staging/irda/net/irttp.c b/drivers/staging/irda/net/irttp.c
index b6ab41d5b3a3..958bfbe38bfb 100644
--- a/drivers/staging/irda/net/irttp.c
+++ b/drivers/staging/irda/net/irttp.c
@@ -403,7 +403,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 		return NULL;
 	}
 
-	self = kzalloc(sizeof(struct tsap_cb), GFP_ATOMIC);
+	self = kzalloc(sizeof(*self), GFP_ATOMIC);
 	if (self == NULL)
 		return NULL;
 
@@ -1441,7 +1441,7 @@ struct tsap_cb *irttp_dup(struct tsap_cb *orig, void *instance)
 	}
 
 	/* Allocate a new instance */
-	new = kmemdup(orig, sizeof(struct tsap_cb), GFP_ATOMIC);
+	new = kmemdup(orig, sizeof(*new), GFP_ATOMIC);
 	if (!new) {
 		pr_debug("%s(), unable to kmalloc\n", __func__);
 		spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);
-- 
2.14.2
