From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/3] net/atm: Improve a size determination in 12 functions
Date: Mon, 9 Oct 2017 22:50:49 +0200
Message-ID: <0ed87fbe-c250-23db-c321-c007f03d31d6@users.sourceforge.net>
References: <10a92558-1105-b947-86a2-6ac763cca36d@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        Bhumika Goyal <bhumirks@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Windsor <dwindsor@gmail.com>,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kees Cook <keescook@chromium.org>,
        Mitchell Blank Jr <mitch@sfgoth.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10a92558-1105-b947-86a2-6ac763cca36d@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 9 Oct 2017 22:00:19 +0200

Replace the specification of data structures by pointer dereferences
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/atm/addr.c        | 2 +-
 net/atm/br2684.c      | 2 +-
 net/atm/clip.c        | 4 ++--
 net/atm/lec.c         | 6 +++---
 net/atm/mpc.c         | 4 ++--
 net/atm/mpoa_caches.c | 4 ++--
 net/atm/signaling.c   | 2 +-
 7 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/atm/addr.c b/net/atm/addr.c
index dcda35c66f15..048e6d192818 100644
--- a/net/atm/addr.c
+++ b/net/atm/addr.c
@@ -86,7 +86,7 @@ int atm_add_addr(struct atm_dev *dev, const struct sockaddr_atmsvc *addr,
 			return -EEXIST;
 		}
 	}
-	this = kmalloc(sizeof(struct atm_dev_addr), GFP_ATOMIC);
+	this = kmalloc(sizeof(*this), GFP_ATOMIC);
 	if (!this) {
 		spin_unlock_irqrestore(&dev->lock, flags);
 		return -ENOMEM;
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 4e111196f902..f5b601c01f38 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -538,7 +538,7 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 
 	if (copy_from_user(&be, arg, sizeof be))
 		return -EFAULT;
-	brvcc = kzalloc(sizeof(struct br2684_vcc), GFP_KERNEL);
+	brvcc = kzalloc(sizeof(*brvcc), GFP_KERNEL);
 	if (!brvcc)
 		return -ENOMEM;
 	/*
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 65f706e4344c..041d519b8771 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -60,7 +60,7 @@ static int to_atmarpd(enum atmarp_ctrl_type type, int itf, __be32 ip)
 	skb = alloc_skb(sizeof(struct atmarp_ctrl), GFP_ATOMIC);
 	if (!skb)
 		return -ENOMEM;
-	ctrl = skb_put(skb, sizeof(struct atmarp_ctrl));
+	ctrl = skb_put(skb, sizeof(*ctrl));
 	ctrl->type = type;
 	ctrl->itf_num = itf;
 	ctrl->ip = ip;
@@ -418,7 +418,7 @@ static int clip_mkip(struct atm_vcc *vcc, int timeout)
 
 	if (!vcc->push)
 		return -EBADFD;
-	clip_vcc = kmalloc(sizeof(struct clip_vcc), GFP_KERNEL);
+	clip_vcc = kmalloc(sizeof(*clip_vcc), GFP_KERNEL);
 	if (!clip_vcc)
 		return -ENOMEM;
 	pr_debug("%p vcc %p\n", clip_vcc, vcc);
diff --git a/net/atm/lec.c b/net/atm/lec.c
index f5be0b931978..74a794602412 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -690,7 +690,7 @@ static int lec_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 	if (ioc_data.dev_num < 0 || ioc_data.dev_num >= MAX_LEC_ITF ||
 	    !dev_lec[ioc_data.dev_num])
 		return -EINVAL;
-	vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL);
+	vpriv = kmalloc(sizeof(*vpriv), GFP_KERNEL);
 	if (!vpriv)
 		return -ENOMEM;
 	vpriv->xoff = 0;
@@ -1552,7 +1552,7 @@ static struct lec_arp_table *make_entry(struct lec_priv *priv,
 {
 	struct lec_arp_table *to_return;
 
-	to_return = kzalloc(sizeof(struct lec_arp_table), GFP_ATOMIC);
+	to_return = kzalloc(sizeof(*to_return), GFP_ATOMIC);
 	if (!to_return)
 		return NULL;
 
@@ -2155,7 +2155,7 @@ static int lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc)
 	struct lec_vcc_priv *vpriv;
 	int err = 0;
 
-	vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL);
+	vpriv = kmalloc(sizeof(*vpriv), GFP_KERNEL);
 	if (!vpriv)
 		return -ENOMEM;
 	vpriv->xoff = 0;
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index dd57d05b5dcc..d6729d797107 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -183,7 +183,7 @@ struct atm_mpoa_qos *atm_mpoa_add_qos(__be32 dst_ip, struct atm_qos *qos)
 		return entry;
 	}
 
-	entry = kmalloc(sizeof(struct atm_mpoa_qos), GFP_KERNEL);
+	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return entry;
 
@@ -279,7 +279,7 @@ static struct mpoa_client *alloc_mpc(void)
 {
 	struct mpoa_client *mpc;
 
-	mpc = kzalloc(sizeof(struct mpoa_client), GFP_KERNEL);
+	mpc = kzalloc(sizeof(*mpc), GFP_KERNEL);
 	if (mpc == NULL)
 		return NULL;
 	rwlock_init(&mpc->ingress_lock);
diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index 7495b42d59eb..23f36e5a20ee 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -96,7 +96,7 @@ static in_cache_entry *in_cache_get_by_vcc(struct atm_vcc *vcc,
 static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 					  struct mpoa_client *client)
 {
-	in_cache_entry *entry = kzalloc(sizeof(in_cache_entry), GFP_KERNEL);
+	in_cache_entry *entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 
 	if (!entry)
 		return NULL;
@@ -456,7 +456,7 @@ static void eg_cache_remove_entry(eg_cache_entry *entry,
 static eg_cache_entry *eg_cache_add_entry(struct k_message *msg,
 					  struct mpoa_client *client)
 {
-	eg_cache_entry *entry = kzalloc(sizeof(eg_cache_entry), GFP_KERNEL);
+	eg_cache_entry *entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 
 	if (!entry)
 		return NULL;
diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 0a20f6e953ac..225234f5cb5f 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -150,7 +150,7 @@ void sigd_enq2(struct atm_vcc *vcc, enum atmsvc_msg_type type,
 	pr_debug("%d (0x%p)\n", (int)type, vcc);
 	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg), GFP_KERNEL)))
 		schedule();
-	msg = skb_put_zero(skb, sizeof(struct atmsvc_msg));
+	msg = skb_put_zero(skb, sizeof(*msg));
 	msg->type = type;
 	*(struct atm_vcc **) &msg->vcc = vcc;
 	*(struct atm_vcc **) &msg->listen_vcc = listen_vcc;
-- 
2.14.2
