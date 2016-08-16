From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 2/4] macsec: show usage even if the module is not available
Date: Tue, 16 Aug 2016 16:26:56 +0200
Message-ID: <bcfcdb764fd467dd112cf1119673386efb03ddfd.1471356460.git.sd@queasysnail.net>
References: <cover.1471356460.git.sd@queasysnail.net>
Cc: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37578 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753391AbcHPO1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 10:27:17 -0400
In-Reply-To: <cover.1471356460.git.sd@queasysnail.net>
In-Reply-To: <cover.1471356460.git.sd@queasysnail.net>
References: <cover.1471356460.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the `ip macsec` command tries to initialize a genl context
even when we just want to see the help for the command, which doesn't
require to talk to the kernel at all.

Delay genl initialization, which can fail if the module isn't loaded,
until the point where we will actually need it.

Fixes: b26fc590ce62 ("ip: add MACsec support")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 ip/ipmacsec.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
index 9eabfe241980..6bd1f54fbfd7 100644
--- a/ip/ipmacsec.c
+++ b/ip/ipmacsec.c
@@ -986,15 +986,15 @@ static int do_show(int argc, char **argv)
 
 int do_ipmacsec(int argc, char **argv)
 {
-	if (genl_init_handle(&genl_rth, MACSEC_GENL_NAME, &genl_family))
-		exit(1);
-
 	if (argc < 1)
 		ipmacsec_usage();
 
 	if (matches(*argv, "help") == 0)
 		ipmacsec_usage();
 
+	if (genl_init_handle(&genl_rth, MACSEC_GENL_NAME, &genl_family))
+		exit(1);
+
 	if (matches(*argv, "show") == 0)
 		return do_show(argc-1, argv+1);
 
-- 
2.9.3
