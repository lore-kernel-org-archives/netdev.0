From: Andreas Steffen <andreas.steffen@hsr.ch>
Subject: static inline int xfrm_mark_get() broken
Date: Mon, 28 Jun 2010 20:46:49 +0200
Message-ID: <4C28EE19.2090502@hsr.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------020600090607000701070809"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hsrmx1.hsr.ch ([152.96.36.50]:48665 "EHLO hsrmx1.hsr.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab0F1S55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 14:57:57 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by hsrmx1.hsr.ch (Postfix) with ESMTP id 8A42321085F
	for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 20:46:53 +0200 (CEST)
Received: from hsrmx1.hsr.ch ([127.0.0.1])
	by localhost (hsrmx1.hsr.ch [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id zkqYOHEV-747 for <netdev@vger.kernel.org>;
	Mon, 28 Jun 2010 20:46:51 +0200 (CEST)
Received: from sid00101.hsr.ch (sid00100.hsr.ch [152.96.20.160])
	by hsrmx1.hsr.ch (Postfix) with ESMTP id CCCCB210840
	for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 20:46:51 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------020600090607000701070809
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

experimenting with the new XFRM_MARK feature of the 2.6.34 kernel
I found out that the extraction of the mark mask might accidentally
work on 64 bit platforms but on 32 bit platforms the function is
awfully broken. The rather trivial patch attached to this mail fixes
the problem. Otherwise the XFRM_MARK feature seems quite promising!

Best regards

Andreas

======================================================================
Andreas Steffen                         e-mail: andreas.steffen@hsr.ch
Institute for Internet Technologies and Applications
Hochschule fuer Technik Rapperswil      phone:  +41 55 222 42 68
CH-8640 Rapperswil (Switzerland)        mobile: +41 76 340 25 56
===========================================================[ITA-HSR]==

--------------020600090607000701070809
Content-Type: text/x-patch; name="xfrm.h.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="xfrm.h.diff"

--- linux/include/net/xfrm.h.ori	2010-06-28 18:53:28.229489876 +0200
+++ linux/include/net/xfrm.h	2010-06-28 18:53:50.745487383 +0200
@@ -1587,7 +1587,7 @@
 static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
 {
 	if (attrs[XFRMA_MARK])
-		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(m));
+		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(struct xfrm_mark));
 	else
 		m->v = m->m = 0;
 

--------------020600090607000701070809--
