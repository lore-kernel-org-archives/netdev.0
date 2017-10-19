From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/8] tools: bpftool: print only one error message on byte parsing failure
Date: Thu, 19 Oct 2017 15:46:23 -0700
Message-ID: <20171019224626.31608-6-jakub.kicinski@netronome.com>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:49472 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753268AbdJSWrL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 18:47:11 -0400
Received: by mail-pf0-f171.google.com with SMTP id i5so8108271pfe.6
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 15:47:11 -0700 (PDT)
In-Reply-To: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

Make error messages more consistent. Specifically, when bpftool fails at
parsing map key bytes, make it print a single error message to stderr
and return from the function, instead of (always) printing a second
error message afterwards.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 tools/bpf/bpftool/map.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/bpf/bpftool/map.c b/tools/bpf/bpftool/map.c
index b1dad76215ed..e1004d825392 100644
--- a/tools/bpf/bpftool/map.c
+++ b/tools/bpf/bpftool/map.c
@@ -252,7 +252,7 @@ static char **parse_bytes(char **argv, const char *name, unsigned char *val,
 		val[i] = strtoul(argv[i], &endptr, 0);
 		if (*endptr) {
 			err("error parsing byte: %s\n", argv[i]);
-			break;
+			return NULL;
 		}
 		i++;
 	}
-- 
2.14.1
