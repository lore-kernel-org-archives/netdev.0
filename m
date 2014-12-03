From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH v2 3/6] emulex: Use skb_put_padto instead of skb_padto() and
 skb->len assignment
Date: Wed, 03 Dec 2014 08:17:46 -0800
Message-ID: <20141203161746.9223.22686.stgit@ahduyck-vm-fedora20>
References: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753700AbaLCQRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 11:17:48 -0500
In-Reply-To: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e0ab767..9461ad8 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1017,9 +1017,8 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 	 * to pad short packets (<= 32 bytes) to a 36-byte length.
 	 */
 	if (unlikely(!BEx_chip(adapter) && skb->len <= 32)) {
-		if (skb_padto(skb, 36))
+		if (skb_put_padto(skb, 36))
 			return NULL;
-		skb->len = 36;
 	}
 
 	if (BEx_chip(adapter) || lancer_chip(adapter)) {
