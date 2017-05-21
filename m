From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/5] atm: Improve a size determination in four functions
Date: Sun, 21 May 2017 22:14:11 +0200
Message-ID: <83404a6d-c7bc-7b06-fa93-0971b1116b9d@users.sourceforge.net>
References: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Kees Cook <keescook@chromium.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 21 May 2017 21:20:44 +0200

Replace the specification of four data structures by pointer dereferences
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/atm/lec.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 09cfe87f0a44..6ad3ca625a44 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -518,5 +518,5 @@ send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
 		return -1;
 	skb->len = sizeof(struct atmlec_msg);
 	mesg = (struct atmlec_msg *)skb->data;
-	memset(mesg, 0, sizeof(struct atmlec_msg));
+	memset(mesg, 0, sizeof(*mesg));
 	mesg->type = type;
@@ -690,5 +690,5 @@ static int lec_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 	if (ioc_data.dev_num < 0 || ioc_data.dev_num >= MAX_LEC_ITF ||
 	    !dev_lec[ioc_data.dev_num])
 		return -EINVAL;
-	vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL);
+	vpriv = kmalloc(sizeof(*vpriv), GFP_KERNEL);
 	if (!vpriv)
@@ -1552,5 +1552,5 @@ static struct lec_arp_table *make_entry(struct lec_priv *priv,
 {
 	struct lec_arp_table *to_return;
 
-	to_return = kzalloc(sizeof(struct lec_arp_table), GFP_ATOMIC);
+	to_return = kzalloc(sizeof(*to_return), GFP_ATOMIC);
 	if (!to_return) {
@@ -2156,5 +2156,5 @@ static int lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc)
 	struct lec_vcc_priv *vpriv;
 	int err = 0;
 
-	vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL);
+	vpriv = kmalloc(sizeof(*vpriv), GFP_KERNEL);
 	if (!vpriv)
-- 
2.13.0

