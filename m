From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipx: correct return type of ipx_map_frame_type
Date: Tue, 16 May 2006 22:49:40 +0400
Message-ID: <20060516184940.GL10143@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:61283 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751876AbWEPSu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 14:50:58 -0400
Received: by nf-out-0910.google.com with SMTP id d4so32555nfe
        for <netdev@vger.kernel.org>; Tue, 16 May 2006 11:50:56 -0700 (PDT)
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Casting BE16 to int and back may or may not work. Correct, to be sure.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -944,9 +944,9 @@ out:
 	return rc;
 }
 
-static int ipx_map_frame_type(unsigned char type)
+static __be16 ipx_map_frame_type(unsigned char type)
 {
-	int rc = 0;
+	__be16 rc = 0;
 
 	switch (type) {
 	case IPX_FRAME_ETHERII:	rc = htons(ETH_P_IPX);		break;

