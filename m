From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 7/7] DCB: Fixes for the setpfcstate and setnumtcs
	command.
Date: Fri, 07 Nov 2008 16:55:07 -0800
Message-ID: <20081108005455.17939.81006.stgit@gitlost.lost>
References: <20081108005042.17939.47091.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Multanen <eric.w.multanen@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:47790
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752707AbYKHAz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 19:55:26 -0500
In-Reply-To: <20081108005042.17939.47091.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Multanen <eric.w.multanen@intel.com>

Removes invalid extra call to the setnumtcs operation.
Fix dcbnl_setpfcstate by referencing the PFC state attribute and calling the setpfcstate operation.

Signed-off-by: Eric Multanen <eric.w.multanen@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/dcb/dcbnl.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index a8e0c79..b2bda3f 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -467,7 +467,6 @@ static int dcbnl_setnumtcs(struct net_device *netdev, struct nlattr **tb,
 	struct nlattr *data[DCB_NUMTCS_ATTR_MAX + 1];
 	int ret = -EINVAL;
 	u8 value;
-	u8 status;
 	int i;
 
 	if (!tb[DCB_ATTR_NUMTCS] || !netdev->dcbnl_ops->setstate)
@@ -490,14 +489,11 @@ static int dcbnl_setnumtcs(struct net_device *netdev, struct nlattr **tb,
 		ret = netdev->dcbnl_ops->setnumtcs(netdev, i, value);
 
 		if (ret)
-			goto err;
+			goto operr;
 	}
 
-	value = nla_get_u8(tb[DCB_ATTR_STATE]);
-
-	status = netdev->dcbnl_ops->setnumtcs(netdev, i, value);
-
-	ret = dcbnl_reply(!!status, RTM_SETDCB, DCB_CMD_SNUMTCS,
+operr:
+	ret = dcbnl_reply(!!ret, RTM_SETDCB, DCB_CMD_SNUMTCS,
 	                  DCB_ATTR_NUMTCS, pid, seq, flags);
 
 err:
@@ -528,9 +524,9 @@ static int dcbnl_setpfcstate(struct net_device *netdev, struct nlattr **tb,
 	if (!tb[DCB_ATTR_PFC_STATE] || !netdev->dcbnl_ops->setpfcstate)
 		return ret;
 
-	value = nla_get_u8(tb[DCB_ATTR_STATE]);
+	value = nla_get_u8(tb[DCB_ATTR_PFC_STATE]);
 
-	netdev->dcbnl_ops->setstate(netdev, value);
+	netdev->dcbnl_ops->setpfcstate(netdev, value);
 
 	ret = dcbnl_reply(0, RTM_SETDCB, DCB_CMD_PFC_SSTATE, DCB_ATTR_PFC_STATE,
 	                  pid, seq, flags);

