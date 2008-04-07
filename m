From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [INET]: sk_reuse is valbool
Date: Mon, 7 Apr 2008 16:01:33 +0100
Message-ID: <20080407150133.GB16869@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:62263 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752896AbYDGPBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 11:01:36 -0400
Received: from gerrit.erg.abdn.ac.uk (Debian-exim@gerrit.erg.abdn.ac.uk [139.133.204.176])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id m37F1WVc001919
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 7 Apr 2008 16:01:32 +0100 (BST)
Received: from gerrit by gerrit.erg.abdn.ac.uk with local (Exim 4.69)
	(envelope-from <gerrit@gerrit.erg.abdn.ac.uk>)
	id 1Jisqj-0004Rd-1B
	for netdev@vger.kernel.org; Mon, 07 Apr 2008 16:01:33 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found this while checking how DCCP handles duplicate bind operations;
it seems it is a remainder of earlier code and now defunct.

-----------------------------------> Patch <---------------------------------------
[INET]: sk_reuse is valbool

sk_reuse is declared as "unsigned char", but is set as type valbool in net/core/sock.c.
There is no other place in net/ where sk->sk_reuse is set to a value > 1, so the test 
"sk_reuse > 1" can not be true.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
--
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -133,8 +133,6 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	goto tb_not_found;
 tb_found:
 	if (!hlist_empty(&tb->owners)) {
-		if (sk->sk_reuse > 1)
-			goto success;
 		if (tb->fastreuse > 0 &&
 		    sk->sk_reuse && sk->sk_state != TCP_LISTEN) {
 			goto success;
-- 


The University of Aberdeen is a charity registered in Scotland, No SC013683.

