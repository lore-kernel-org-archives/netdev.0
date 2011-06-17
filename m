From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 7/7] dcb: Add missing error check in dcb_ieee_set()
Date: Fri, 17 Jun 2011 14:16:45 -0700
Message-ID: <20110617211645.26578.49949.stgit@jf-dev1-dcblab>
References: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11059 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758014Ab1FQVXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 17:23:17 -0400
In-Reply-To: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Missing error checking before nla_parse_nested().

Reported-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/dcb/dcbnl.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 28fc386..e48879f 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1367,6 +1367,9 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlattr **tb,
 	if (!ops)
 		return err;
 
+	if (!tb[DCB_ATTR_IEEE])
+		return -EINVAL;
+
 	err = nla_parse_nested(ieee, DCB_ATTR_IEEE_MAX,
 			       tb[DCB_ATTR_IEEE], dcbnl_ieee_policy);
 	if (err)

