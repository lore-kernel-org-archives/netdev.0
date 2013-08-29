From: Thomas Egerer <thomas.egerer@secunet.com>
Subject: [PATCH] ip/xfrm: Fix potential SIGSEGV when printing extra flags
Date: Thu, 29 Aug 2013 14:00:36 +0200
Message-ID: <521F37E4.9030501@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010205020908000603010104"
Cc: shemminger@osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60553 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752276Ab3H2M1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 08:27:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010205020908000603010104
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit


The git-commit dc8867d0, that added support for displaying the
extra-flags of a state, introduced a potential segfault.
Trying to show a state without the extra-flag attribute and show_stats
enabled, would cause the NULL pointer in tb[XFRMA_SA_EXTRA_FLAGS] to be
dereferenced.

Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
---
 ip/ipxfrm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)




--------------010205020908000603010104
Content-Type: text/x-patch;
 name="0001-ip-xfrm-Fix-potential-SIGSEGV-when-printing-extra-fl.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ip-xfrm-Fix-potential-SIGSEGV-when-printing-extra-fl.pa";
 filename*1="tch"

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 0a3a9fb..411d9d5 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -856,7 +856,7 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 		if (flags)
 			fprintf(fp, "%x", flags);
 	}
-	if (show_stats > 0 || tb[XFRMA_SA_EXTRA_FLAGS]) {
+	if (show_stats > 0 && tb[XFRMA_SA_EXTRA_FLAGS]) {
 		__u32 extra_flags = *(__u32 *)RTA_DATA(tb[XFRMA_SA_EXTRA_FLAGS]);
 
 		fprintf(fp, "extra_flag ");


--------------010205020908000603010104--
