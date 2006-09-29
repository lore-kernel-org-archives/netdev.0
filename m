From: David Woodhouse <dwmw2@infradead.org>
Subject: [MLSXFRM] Fix mis-labelling of child sockets
Date: Fri, 29 Sep 2006 22:18:01 +0100
Message-ID: <1159564681.3309.431.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Paul Moore <paul.moore@hp.com>,
	James Morris <jmorris@redhat.com>,
	Venkat Yekkirala <vyekkirala@trustedcs.com>,
	Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44011 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751437AbWI2VS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 17:18:27 -0400
To: torvalds@osdl.org, akpm@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Accepted connections of types other than AF_INET, AF_INET6, AF_UNIX
won't have an appropriate label derived from the peer, so don't use it.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>
Acked-by:  Stephen Smalley <sds@tycho.nsa.gov>

--- linux-2.6.18.ppc/security/selinux/hooks.c~	2006-09-28 14:37:20.000000000 +0100
+++ linux-2.6.18.ppc/security/selinux/hooks.c	2006-09-29 19:00:25.000000000 +0100
@@ -3604,7 +3604,9 @@ void selinux_sock_graft(struct sock* sk,
 	struct inode_security_struct *isec = SOCK_INODE(parent)->i_security;
 	struct sk_security_struct *sksec = sk->sk_security;
 
-	isec->sid = sksec->sid;
+	if (sk->sk_family == PF_INET || sk->sk_family == PF_INET6 ||
+	    sk->sk_family == PF_UNIX)
+		isec->sid = sksec->sid;
 
 	selinux_netlbl_sock_graft(sk, parent);
 }

-- 
dwmw2

