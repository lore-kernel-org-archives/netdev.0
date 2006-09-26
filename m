From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Fix order in inet_init failure path.
Date: Tue, 26 Sep 2006 16:17:09 +0200
Message-ID: <20060926141709.GA19722@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41893 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1750701AbWIZORL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 10:17:11 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id E397F20F48
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:09 +0200 (CEST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is just a minor buglet I came across by accident - when inet_init
fails to register raw_prot, it jumps to out_unregister_udp_proto which
should unregister UDP _and_ TCP.

Signed-off-by: Olaf Kirch <okir@suse.de>

 net/ipv4/af_inet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: build/net/ipv4/af_inet.c
===================================================================
--- build.orig/net/ipv4/af_inet.c
+++ build/net/ipv4/af_inet.c
@@ -1345,10 +1345,10 @@ static int __init inet_init(void)
 	rc = 0;
 out:
 	return rc;
-out_unregister_tcp_proto:
-	proto_unregister(&tcp_prot);
 out_unregister_udp_proto:
 	proto_unregister(&udp_prot);
+out_unregister_tcp_proto:
+	proto_unregister(&tcp_prot);
 	goto out;
 }
 

-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
