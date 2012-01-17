From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] inetpeer: initialize ->redirect_genid in inet_getpeer()
Date: Tue, 17 Jan 2012 23:48:43 +0300
Message-ID: <20120117204843.GA20999@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:40637 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550Ab2AQUtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 15:49:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kmemcheck complains that ->redirect_genid doesn't get initialized.
Presumably it should be set to zero.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 86f13c67..49ce5f4 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -447,6 +447,7 @@ relookup:
 		p->rate_last = 0;
 		p->pmtu_expires = 0;
 		p->pmtu_orig = 0;
+		p->redirect_genid = 0;
 		memset(&p->redirect_learned, 0, sizeof(p->redirect_learned));
 
 
