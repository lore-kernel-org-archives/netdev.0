From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: [PATCH] fix validate_link_af in rtnetlink core
Date: Wed, 26 Jan 2011 15:55:24 +0100
Message-ID: <20110126145523.GA3171@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:20971 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813Ab1AZOz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 09:55:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm not sure about this patch.

I'm testing an API that uses IFLA_AF_SPEC attribute.
In the rtnetlink core , the set_link_af() member
of the rtnl_af_ops struct receives the nested attribute
(as I expected), but the validate_link_af() member
receives the parent attribute.
IMO, this patch fixes this.

Since I didn't find any code in iproute2 that makes use
of this attribute, I wasn't able to verify this on the userspace
end.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
---
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 310eb80..c6aee92 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1122,8 +1122,7 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
 				return -EOPNOTSUPP;
 
 			if (af_ops->validate_link_af) {
-				err = af_ops->validate_link_af(dev,
-							tb[IFLA_AF_SPEC]);
+				err = af_ops->validate_link_af(dev, af);
 				if (err < 0)
 					return err;
 			}
