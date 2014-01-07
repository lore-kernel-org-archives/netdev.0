From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 2/2] include/uapi/linux/xfrm.h: Pack struct xfrm_usersa_info
Date: Tue, 7 Jan 2014 14:48:59 +0800
Message-ID: <1389077339-12814-3-git-send-email-fan.du@windriver.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>,
	<dev@lists.strongswan.org>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:56471 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459AbaAGGtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 01:49:12 -0500
In-Reply-To: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise 64bits kernel has sizeof(struct xfrm_usersa_info) 224 bytes,
while 32bits compiled iproute2 see the same structure as 220 bytes, which
leading deficit xfrm sa, in turn broken IPsec connectivity.

Fix this by packing the structure.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/uapi/linux/xfrm.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 470bfae..61460c4 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -366,7 +366,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_AF_UNSPEC	32
 #define XFRM_STATE_ALIGN4	64
 #define XFRM_STATE_ESN		128
-};
+} __attribute__((packed));
 
 #define XFRM_SA_XFLAG_DONT_ENCAP_DSCP	1
 
-- 
1.7.9.5
