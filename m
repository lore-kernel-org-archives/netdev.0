From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/2] net: add error return for dcb setstate
Date: Fri, 12 Dec 2008 01:52:21 -0800
Message-ID: <20081212095221.4416.83327.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Eric W Multanen <eric.w.multanen@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:58269
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752905AbYLLJwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 04:52:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

DCB had no way to know if setstate had failed in the driver. This
patch enables dcb netlink code to handle the status for the DCB
setstate interface.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/net/dcbnl.h |    2 +-
 net/dcb/dcbnl.c     |    5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 91e0a3d..775cfc8 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -26,7 +26,7 @@
  */
 struct dcbnl_rtnl_ops {
 	u8   (*getstate)(struct net_device *);
-	void (*setstate)(struct net_device *, u8);
+	u8   (*setstate)(struct net_device *, u8);
 	void (*getpermhwaddr)(struct net_device *, u8 *);
 	void (*setpgtccfgtx)(struct net_device *, int, u8, u8, u8, u8);
 	void (*setpgbwgcfgtx)(struct net_device *, int, u8);
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 79a351d..d0c12f0 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -714,9 +714,8 @@ static int dcbnl_setstate(struct net_device *netdev, struct nlattr **tb,
 
 	value = nla_get_u8(tb[DCB_ATTR_STATE]);
 
-	netdev->dcbnl_ops->setstate(netdev, value);
-
-	ret = dcbnl_reply(0, RTM_SETDCB, DCB_CMD_SSTATE, DCB_ATTR_STATE,
+	ret = dcbnl_reply(netdev->dcbnl_ops->setstate(netdev, value),
+	                  RTM_SETDCB, DCB_CMD_SSTATE, DCB_ATTR_STATE,
 	                  pid, seq, flags);
 
 	return ret;

