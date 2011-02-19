From: Joe Perches <joe@perches.com>
Subject: [PATCH] connector: Convert char *name to const char *name
Date: Sat, 19 Feb 2011 15:45:29 -0800
Message-ID: <1298159129.7179.32.camel@Joe-Laptop>
References: <1298151834-13141-1-git-send-email-martinez.javier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>, devel@driverdev.osuosl.org,
	"K. Y. Srinivasan" <ksrinivasan@novell.com>,
	netdev <netdev@vger.kernel.org>
To: Javier Martinez Canillas <martinez.javier@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3787 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754599Ab1BSXpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Feb 2011 18:45:31 -0500
In-Reply-To: <1298151834-13141-1-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow more const declarations.

Signed-off-by: Joe Perches <joe@perches.com>

---

Better to change the declarations and uses as this argument
is not modified.

On Sat, 2011-02-19 at 22:43 +0100, Javier Martinez Canillas wrote:
> cn_add_callback() defines is second argument as a char * but a
> const char * was supplied instead. So the compiler generates a  
> compile warning.

 drivers/connector/cn_queue.c  |    7 ++++---
 drivers/connector/connector.c |    2 +-
 include/linux/connector.h     |    9 ++++++---
 3 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index 81270d2..55653ab 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -48,7 +48,7 @@ void cn_queue_wrapper(struct work_struct *work)
 }
 
 static struct cn_callback_entry *
-cn_queue_alloc_callback_entry(char *name, struct cb_id *id,
+cn_queue_alloc_callback_entry(const char *name, struct cb_id *id,
 			      void (*callback)(struct cn_msg *, struct netlink_skb_parms *))
 {
 	struct cn_callback_entry *cbq;
@@ -78,7 +78,8 @@ int cn_cb_equal(struct cb_id *i1, struct cb_id *i2)
 	return ((i1->idx == i2->idx) && (i1->val == i2->val));
 }
 
-int cn_queue_add_callback(struct cn_queue_dev *dev, char *name, struct cb_id *id,
+int cn_queue_add_callback(struct cn_queue_dev *dev, const char *name,
+			  struct cb_id *id,
 			  void (*callback)(struct cn_msg *, struct netlink_skb_parms *))
 {
 	struct cn_callback_entry *cbq, *__cbq;
@@ -135,7 +136,7 @@ void cn_queue_del_callback(struct cn_queue_dev *dev, struct cb_id *id)
 	}
 }
 
-struct cn_queue_dev *cn_queue_alloc_dev(char *name, struct sock *nls)
+struct cn_queue_dev *cn_queue_alloc_dev(const char *name, struct sock *nls)
 {
 	struct cn_queue_dev *dev;
 
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 05117f1..f7554de 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -205,7 +205,7 @@ static void cn_rx_skb(struct sk_buff *__skb)
  *
  * May sleep.
  */
-int cn_add_callback(struct cb_id *id, char *name,
+int cn_add_callback(struct cb_id *id, const char *name,
 		    void (*callback)(struct cn_msg *, struct netlink_skb_parms *))
 {
 	int err;
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 2e9759c..a9edf24 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -129,14 +129,17 @@ struct cn_dev {
 	struct cn_queue_dev *cbdev;
 };
 
-int cn_add_callback(struct cb_id *, char *, void (*callback) (struct cn_msg *, struct netlink_skb_parms *));
+int cn_add_callback(struct cb_id *id, const char *name,
+		    void (*callback)(struct cn_msg *, struct netlink_skb_parms *));
 void cn_del_callback(struct cb_id *);
 int cn_netlink_send(struct cn_msg *, u32, gfp_t);
 
-int cn_queue_add_callback(struct cn_queue_dev *dev, char *name, struct cb_id *id, void (*callback)(struct cn_msg *, struct netlink_skb_parms *));
+int cn_queue_add_callback(struct cn_queue_dev *dev, const char *name,
+			  struct cb_id *id,
+			  void (*callback)(struct cn_msg *, struct netlink_skb_parms *));
 void cn_queue_del_callback(struct cn_queue_dev *dev, struct cb_id *id);
 
-struct cn_queue_dev *cn_queue_alloc_dev(char *name, struct sock *);
+struct cn_queue_dev *cn_queue_alloc_dev(const char *name, struct sock *);
 void cn_queue_free_dev(struct cn_queue_dev *dev);
 
 int cn_cb_equal(struct cb_id *, struct cb_id *);


