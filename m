From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipx: endian bug in ipxrtr_route_packet()
Date: Sun, 4 Jun 2006 03:36:04 +0400
Message-ID: <20060603233603.GB7268@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:2981 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932620AbWFCXfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 19:35:07 -0400
Received: by ug-out-1314.google.com with SMTP id a2so900971ugf
        for <netdev@vger.kernel.org>; Sat, 03 Jun 2006 16:35:06 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 Also, there is the following snippet in net/ipx/af_ipx.c, line 1174

	f.ipx_special = sipx->sipx_special;

 The former is unsigned char and is compared with 1 and 2. The latter is
 __be16 if I'm not mistaken. Is there a bug hiding?

--- a/net/ipx/ipx_route.c
+++ b/net/ipx/ipx_route.c
@@ -238,7 +237,7 @@ int ipxrtr_route_packet(struct sock *sk,
 	}	
 
 	/* Apply checksum. Not allowed on 802.3 links. */
-	if (sk->sk_no_check || intrfc->if_dlink_type == IPX_FRAME_8023)
+	if (sk->sk_no_check || intrfc->if_dlink_type == htons(IPX_FRAME_8023))
 		ipx->ipx_checksum = 0xFFFF;
 	else
 		ipx->ipx_checksum = ipx_cksum(ipx, len + sizeof(struct ipxhdr));

