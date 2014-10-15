From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] NFC: netlink: use sizeof(*iter) instead of class_dev_iter
Date: Wed, 15 Oct 2014 21:03:00 +0200
Message-ID: <1413399780-8470-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also fixes kzalloc on struct se_io_ctx
See Documentation/CodingStyle Chapter 14

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/nfc/netlink.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 43cb1c1..b4ba68e 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -534,7 +534,7 @@ static int nfc_genl_dump_devices(struct sk_buff *skb,
 
 	if (!iter) {
 		first_call = true;
-		iter = kmalloc(sizeof(struct class_dev_iter), GFP_KERNEL);
+		iter = kmalloc(sizeof(*iter), GFP_KERNEL);
 		if (!iter)
 			return -ENOMEM;
 		cb->args[0] = (long) iter;
@@ -1242,7 +1242,7 @@ static int nfc_genl_dump_ses(struct sk_buff *skb,
 
 	if (!iter) {
 		first_call = true;
-		iter = kmalloc(sizeof(struct class_dev_iter), GFP_KERNEL);
+		iter = kmalloc(sizeof(*iter), GFP_KERNEL);
 		if (!iter)
 			return -ENOMEM;
 		cb->args[0] = (long) iter;
@@ -1360,7 +1360,7 @@ static int nfc_genl_se_io(struct sk_buff *skb, struct genl_info *info)
 	if (!apdu)
 		return -EINVAL;
 
-	ctx = kzalloc(sizeof(struct se_io_ctx), GFP_KERNEL);
+	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
 	if (!ctx)
 		return -ENOMEM;
 
-- 
1.9.3
