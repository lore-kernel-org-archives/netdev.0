From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 1/2] bnx2x: remove zeroing of dump data buffer
Date: Mon,  1 Jul 2013 17:23:05 +0200
Message-ID: <1372692186-31032-2-git-send-email-mschmidt@redhat.com>
References: <1372692186-31032-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, Miriam Shitrit <miris@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48681 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807Ab3GAPXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 11:23:11 -0400
In-Reply-To: <1372692186-31032-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to initialize the dump data with zeros.
data is allocated with vzalloc, so it's already zero-filled.

More importantly, the memset is harmful, because dump->len (the length
requested by userspace) can be bigger than the allocated buffer (whose
size is determined by asking the driver's .get_dump_flag method).

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index ce1a916..61ccae5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -986,8 +986,6 @@ static int bnx2x_get_dump_data(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 	struct dump_header dump_hdr = {0};
 
-	memset(p, 0, dump->len);
-
 	/* Disable parity attentions as long as following dump may
 	 * cause false alarms by reading never written registers. We
 	 * will re-enable parity attentions right after the dump.
-- 
1.8.1.4
