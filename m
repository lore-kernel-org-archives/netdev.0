From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/3] net/atm: Delete an error message for a failed memory
 allocation in five functions
Date: Mon, 9 Oct 2017 22:49:33 +0200
Message-ID: <5270f15b-5e97-0c3e-3e55-fbded48ae07d@users.sourceforge.net>
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
Date: Mon, 9 Oct 2017 21:34:35 +0200

Omit extra messages for a memory allocation failure in these functions.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/atm/lec.c         | 5 ++---
 net/atm/mpc.c         | 8 ++------
 net/atm/mpoa_caches.c | 8 ++------
 3 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index a3d93a1bb133..f5be0b931978 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1553,10 +1553,9 @@ static struct lec_arp_table *make_entry(struct lec_priv *priv,
 	struct lec_arp_table *to_return;
 
 	to_return = kzalloc(sizeof(struct lec_arp_table), GFP_ATOMIC);
-	if (!to_return) {
-		pr_info("LEC: Arp entry kmalloc failed\n");
+	if (!to_return)
 		return NULL;
-	}
+
 	ether_addr_copy(to_return->mac_addr, mac_addr);
 	INIT_HLIST_NODE(&to_return->next);
 	setup_timer(&to_return->timer, lec_arp_expire_arp,
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 5677147209e8..dd57d05b5dcc 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -184,10 +184,8 @@ struct atm_mpoa_qos *atm_mpoa_add_qos(__be32 dst_ip, struct atm_qos *qos)
 	}
 
 	entry = kmalloc(sizeof(struct atm_mpoa_qos), GFP_KERNEL);
-	if (entry == NULL) {
-		pr_info("mpoa: out of memory\n");
+	if (!entry)
 		return entry;
-	}
 
 	entry->ipaddr = dst_ip;
 	entry->qos = *qos;
@@ -473,10 +471,8 @@ static const uint8_t *copy_macs(struct mpoa_client *mpc,
 			kfree(mpc->mps_macs);
 		mpc->number_of_mps_macs = 0;
 		mpc->mps_macs = kmalloc(num_macs * ETH_ALEN, GFP_KERNEL);
-		if (mpc->mps_macs == NULL) {
-			pr_info("(%s) out of mem\n", mpc->dev->name);
+		if (!mpc->mps_macs)
 			return NULL;
-		}
 	}
 	ether_addr_copy(mpc->mps_macs, router_mac);
 	tlvs += 20; if (device_type == MPS_AND_MPC) tlvs += 20;
diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index 4ccaa16b1eb1..7495b42d59eb 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -98,10 +98,8 @@ static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 {
 	in_cache_entry *entry = kzalloc(sizeof(in_cache_entry), GFP_KERNEL);
 
-	if (entry == NULL) {
-		pr_info("mpoa: mpoa_caches.c: new_in_cache_entry: out of memory\n");
+	if (!entry)
 		return NULL;
-	}
 
 	dprintk("adding an ingress entry, ip = %pI4\n", &dst_ip);
 
@@ -460,10 +458,8 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg,
 {
 	eg_cache_entry *entry = kzalloc(sizeof(eg_cache_entry), GFP_KERNEL);
 
-	if (entry == NULL) {
-		pr_info("out of memory\n");
+	if (!entry)
 		return NULL;
-	}
 
 	dprintk("adding an egress entry, ip = %pI4, this should be our IP\n",
 		&msg->content.eg_info.eg_dst_ip);
-- 
2.14.2
