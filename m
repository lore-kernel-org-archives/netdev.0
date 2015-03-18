From: roopa@cumulusnetworks.com
Subject: [PATCH iproute2] lib utils: fix family during af_bit_len calculation
Date: Tue, 17 Mar 2015 19:18:28 -0700
Message-ID: <1426645109-3411-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, vadim4j@gmail.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36808 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbbCRCSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 22:18:34 -0400
Received: by pdbcz9 with SMTP id cz9so27463337pdb.3
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 19:18:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

commit f3a2ddc124e0 ("lib utils: Use helpers to get AF bit/byte len")
used a wrong family or family of zero in the default case
during af_bit_len calculation causing ip route commands to
fail with below error

Error: an inet prefix is expected rather than "10.0.2.14/24".

Reported-by: Sven-Haegar Koch <haegar@sdinet.de>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 lib/utils.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/utils.c b/lib/utils.c
index 9cda268..0d08a86 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -477,7 +477,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 
 	err = get_addr_1(dst, arg, family);
 	if (err == 0) {
-		dst->bitlen = af_bit_len(family);
+		dst->bitlen = af_bit_len(dst->family);
 
 		if (slash) {
 			if (get_netmask(&plen, slash+1, 0)
-- 
1.7.10.4
