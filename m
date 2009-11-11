From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] netfilter: Should xt_osf_remove_callback() return negative
 on errors?
Date: Wed, 11 Nov 2009 23:33:01 +0100
Message-ID: <4AFB3B9D.1080606__42203.0469090261$1257978258$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kerne
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:23182 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759221AbZKKWU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 17:20:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return a negative error value

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 net/netfilter/xt_osf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

It seems strange that an error return can be positive or
negative, is this maybe required?

diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 63e1905..4d1a41b 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -118,7 +118,7 @@ static int xt_osf_remove_callback(struct sock *ctnl, struct sk_buff *skb,
 {
 	struct xt_osf_user_finger *f;
 	struct xt_osf_finger *sf;
-	int err = ENOENT;
+	int err = -ENOENT;
 
 	if (!osf_attrs[OSF_ATTR_FINGER])
 		return -EINVAL;
