From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: [Patch] Dead code in net/sunrpc/auth_gss/auth_gss.c
Date: Tue, 18 Apr 2006 18:07:11 +0200
Message-ID: <1145376431.11649.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dugsong@monkey.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:41155 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1751064AbWDRQHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 12:07:14 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

the coverity checker spotted that cred is always NULL
when we jump to out_err ( there is just one case, when
we fail to allocate the memory for cred )
This is Coverity ID #79

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

--- linux-2.6.17-rc1/net/sunrpc/auth_gss/auth_gss.c.orig	2006-04-18 13:23:22.000000000 +0200
+++ linux-2.6.17-rc1/net/sunrpc/auth_gss/auth_gss.c	2006-04-18 13:24:10.000000000 +0200
@@ -794,7 +794,6 @@ gss_create_cred(struct rpc_auth *auth, s
 
 out_err:
 	dprintk("RPC:      gss_create_cred failed with error %d\n", err);
-	if (cred) gss_destroy_cred(&cred->gc_base);
 	return ERR_PTR(err);
 }
 


