From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 2/2] net: fix dcbnl_setnumtcs operation check
Date: Fri, 12 Dec 2008 01:52:45 -0800
Message-ID: <20081212095244.4416.19017.stgit@lost.foo-projects.org>
References: <20081212095221.4416.83327.stgit@lost.foo-projects.org>
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
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:60169
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756541AbYLLJxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 04:53:08 -0500
In-Reply-To: <20081212095221.4416.83327.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

dcbml_setnumtcs wasn't checking for the presence of the setnumtcs
function.  Instead, it was checking for setstate which was a bug.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/dcb/dcbnl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index d0c12f0..fc88fc4 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -469,7 +469,7 @@ static int dcbnl_setnumtcs(struct net_device *netdev, struct nlattr **tb,
 	u8 value;
 	int i;
 
-	if (!tb[DCB_ATTR_NUMTCS] || !netdev->dcbnl_ops->setstate)
+	if (!tb[DCB_ATTR_NUMTCS] || !netdev->dcbnl_ops->setnumtcs)
 		return ret;
 
 	ret = nla_parse_nested(data, DCB_NUMTCS_ATTR_MAX, tb[DCB_ATTR_NUMTCS],

