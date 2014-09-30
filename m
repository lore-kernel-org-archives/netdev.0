From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] irda: add __init to irlan_open
Date: Tue, 30 Sep 2014 22:24:04 +0200
Message-ID: <1412108644-6547-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

irlan_open is only called by __init irlan_init in same module.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/irda/irlan/irlan_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 1bc49ed..5a2d0a6 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -98,7 +98,7 @@ static const struct file_operations irlan_fops = {
 extern struct proc_dir_entry *proc_irda;
 #endif /* CONFIG_PROC_FS */
 
-static struct irlan_cb *irlan_open(__u32 saddr, __u32 daddr);
+static struct irlan_cb __init *irlan_open(__u32 saddr, __u32 daddr);
 static void __irlan_close(struct irlan_cb *self);
 static int __irlan_insert_param(struct sk_buff *skb, char *param, int type,
 				__u8 value_byte, __u16 value_short,
@@ -196,7 +196,7 @@ static void __exit irlan_cleanup(void)
  *    Open new instance of a client/provider, we should only register the
  *    network device if this instance is ment for a particular client/provider
  */
-static struct irlan_cb *irlan_open(__u32 saddr, __u32 daddr)
+static struct irlan_cb __init *irlan_open(__u32 saddr, __u32 daddr)
 {
 	struct net_device *dev;
 	struct irlan_cb *self;
-- 
1.9.3
