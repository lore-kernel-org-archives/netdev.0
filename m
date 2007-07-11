From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: Fix meta ematch usage of 0 values
Date: Wed, 11 Jul 2007 14:48:12 +0200
Message-ID: <4694D18C.1060400@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030000060202070501090309"
Cc: Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52239 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760550AbXGKMsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 08:48:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030000060202070501090309
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------030000060202070501090309
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPROUTE]: Fix meta ematch usage of 0 values

em_meta doesn't send 0 values to the kernel. breaking matching on them and
resulting in "Missing value TLV" messages on dump.

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/tc/em_meta.c b/tc/em_meta.c
index 5fc0c59..b727422 100644
--- a/tc/em_meta.c
+++ b/tc/em_meta.c
@@ -406,11 +406,8 @@ static int meta_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 
 	addattr_l(n, MAX_MSG, TCA_EM_META_HDR, &meta_hdr, sizeof(meta_hdr));
 
-	if (lvalue)
-		dump_value(n, TCA_EM_META_LVALUE, lvalue, &meta_hdr.left);
-
-	if (rvalue)
-		dump_value(n, TCA_EM_META_RVALUE, rvalue, &meta_hdr.right);
+	dump_value(n, TCA_EM_META_LVALUE, lvalue, &meta_hdr.left);
+	dump_value(n, TCA_EM_META_RVALUE, rvalue, &meta_hdr.right);
 
 	return 0;
 }

--------------030000060202070501090309--
