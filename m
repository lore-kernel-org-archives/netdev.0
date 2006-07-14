From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] orinoco: fix setting transmit key only
Date: Fri, 14 Jul 2006 11:41:47 -0400
Message-ID: <1152891707.14037.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, Pavel Roskin <proski@gnu.org>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:19166 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1161131AbWGNPn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 11:43:26 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When determining whether there's a key to set or not, orinoco should be
looking at the key length, not the key data.  Otherwise confusion reigns
when trying to set TX key only, passing in zero-length key, but non-NULL
pointer.  Key length takes precedence over non-NULL key data.

Signed-off-by: Dan Williams <dcbw@redhat.com>

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index 8a31b59..1e69bc6 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -2876,7 +2876,7 @@ static int orinoco_ioctl_setiwencode(str
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
 
-	if (erq->pointer) {
+	if (erq->length > 0) {
 		if ((index < 0) || (index >= ORINOCO_MAX_KEYS))
 			index = priv->tx_key;
 
@@ -2919,7 +2919,7 @@ static int orinoco_ioctl_setiwencode(str
 	if (erq->flags & IW_ENCODE_RESTRICTED)
 		restricted = 1;
 
-	if (erq->pointer) {
+	if (erq->pointer && erq->length > 0) {
 		priv->keys[index].len = cpu_to_le16(xlen);
 		memset(priv->keys[index].data, 0,
 		       sizeof(priv->keys[index].data));


