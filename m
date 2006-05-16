From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipx: correct return type of ipxrtr_delete
Date: Wed, 17 May 2006 00:12:38 +0400
Message-ID: <20060516201238.GM10143@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:33583 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750776AbWEPUOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 16:14:01 -0400
Received: by nf-out-0910.google.com with SMTP id a27so7646nfc
        for <netdev@vger.kernel.org>; Tue, 16 May 2006 13:14:00 -0700 (PDT)
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A single caller passes __u32. Inside function "net" is compared with
__u32 (__be32 really, just wasn't annotated).

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

--- a/net/ipx/ipx_route.c
+++ b/net/ipx/ipx_route.c
@@ -119,7 +119,7 @@ out:
 	return rc;
 }
 
-static int ipxrtr_delete(long net)
+static int ipxrtr_delete(__u32 net)
 {
 	struct ipx_route *r, *tmp;
 	int rc;

