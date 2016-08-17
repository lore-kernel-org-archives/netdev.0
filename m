From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/3] net: veth: Set features for MPLS
Date: Wed, 17 Aug 2016 14:49:47 -0700
Message-ID: <1471470587-24813-4-git-send-email-dsa@cumulusnetworks.com>
References: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com>
Cc: buytenh@wantstofly.org, simon.horman@netronome.com,
	ebiederm@xmission.com, rshearma@brocade.com, tom@herbertland.com,
	tgraf@suug.ch, olivier.dugeon@orange.com,
	alexander.duyck@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33005 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495AbcHQVvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 17:51:08 -0400
Received: by mail-pa0-f42.google.com with SMTP id ti13so244481pac.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 14:51:08 -0700 (PDT)
In-Reply-To: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

veth does not really transmit packets only moves the skb from one
netdev to another so gso and checksum is not really needed. Add
the features to mpls_features to get the same benefit and performance
with MPLS as without it.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/veth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f37a6e61d4ad..5db320a4d5cf 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -340,6 +340,7 @@ static void veth_setup(struct net_device *dev)
 
 	dev->hw_features = VETH_FEATURES;
 	dev->hw_enc_features = VETH_FEATURES;
+	dev->mpls_features = NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE;
 }
 
 /*
-- 
2.1.4
