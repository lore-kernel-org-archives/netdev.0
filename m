From: "Andrey Jr. Melnikov" <temnota.am@gmail.com>
Subject: [PATCH] iproute: disallow ip rule del without parameters
Date: Wed, 24 Aug 2016 23:43:00 +0300
Message-ID: <20160824204252.2melotzdx6ftzgaq@ppc.Dlink>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35436 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752059AbcHXUnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 16:43:05 -0400
Received: by mail-lf0-f68.google.com with SMTP id l89so1488060lfi.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 13:43:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disallow run `ip rule del` without any parameter to avoid delete any first
rule from table.

Signed-off-by: Andrey Jr. Melnikov <temnota.am@gmail.com>
---

diff --git a/ip/iprule.c b/ip/iprule.c
index 8f24206..70562c5 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -346,6 +346,11 @@ static int iprule_modify(int cmd, int argc, char **argv)
 		req.r.rtm_type = RTN_UNICAST;
 	}
 
+	if (cmd == RTM_DELRULE && argc == 0) {
+		fprintf(stderr, "\"ip rule del\" requires arguments.\n");
+		return -1;
+	}
+
 	while (argc > 0) {
 		if (strcmp(*argv, "not") == 0) {
 			req.r.rtm_flags |= FIB_RULE_INVERT;
