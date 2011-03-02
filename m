From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-2.6 PATCH] net: dcbnl: check correct ops in dcbnl_ieee_set()
Date: Wed, 02 Mar 2011 12:35:33 -0800
Message-ID: <20110302203533.2465.11134.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, davem@davemloft.net,
	shmulikr@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:16027 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754696Ab1CBUky (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 15:40:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The incorrect ops routine was being tested for in
DCB_ATTR_IEEE_PFC attributes. This patch corrects
it.

Currently, every driver implementing ieee_setets also
implements ieee_setpfc so this bug is not actualized
yet.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/dcb/dcbnl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index d5074a5..c44348a 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1193,7 +1193,7 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlattr **tb,
 			goto err;
 	}
 
-	if (ieee[DCB_ATTR_IEEE_PFC] && ops->ieee_setets) {
+	if (ieee[DCB_ATTR_IEEE_PFC] && ops->ieee_setpfc) {
 		struct ieee_pfc *pfc = nla_data(ieee[DCB_ATTR_IEEE_PFC]);
 		err = ops->ieee_setpfc(netdev, pfc);
 		if (err)

