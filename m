From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/2] NFC: delete null dereference
Date: Sat, 17 Oct 2015 11:32:19 +0200
Message-ID: <1445074340-21955-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1445074340-21955-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1445074340-21955-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The exit label performs device_unlock(&dev->dev);, which will fail when dev
is NULL, and nfc_put_device(dev);, which is not useful when dev is NULL, so
just exit the function immediately.

Problem found using scripts/coccinelle/null/deref_null.cocci

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/nfc/netlink.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 853172c..f040532 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -1109,10 +1109,8 @@ static int nfc_genl_llc_sdreq(struct sk_buff *skb, struct genl_info *info)
 	idx = nla_get_u32(info->attrs[NFC_ATTR_DEVICE_INDEX]);
 
 	dev = nfc_get_device(idx);
-	if (!dev) {
-		rc = -ENODEV;
-		goto exit;
-	}
+	if (!dev)
+		return -ENODEV;
 
 	device_lock(&dev->dev);
 

