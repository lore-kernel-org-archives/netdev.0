From: philipp@redfish-solutions.com
Subject: [PATCH] iproute2: Fix case of -o (oneline) broken in xfrm
Date: Mon, 16 Mar 2015 16:06:49 -0600
Message-ID: <20150316_220649_065662.philipp@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=usascii
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:33255 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753677AbbCPWNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 18:13:52 -0400
Received: from [192.168.1.10] (builder.redfish-solutions.com [192.168.1.10])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.8/8.14.8) with ESMTP id t2GM6nuI005655
	for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 16:06:49 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't insert newline in -o mode; print mark as hex.
    
Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
---
 ip/ipxfrm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index f55bff9..810a2bf 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -694,7 +694,7 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 	if (tb[XFRMA_MARK]) {
 		struct rtattr *rta = tb[XFRMA_MARK];
 		struct xfrm_mark *m = (struct xfrm_mark *) RTA_DATA(rta);
-		fprintf(fp, "\tmark %d/0x%x\n", m->v, m->m);
+		fprintf(fp, "\tmark %#x/%#x%s", m->v, m->m, _SL_);
 	}
 
 	if (tb[XFRMA_ALG_AUTH] && !tb[XFRMA_ALG_AUTH_TRUNC]) {
