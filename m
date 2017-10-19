From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/8] tools: bpftool: use err() instead of info() if there are too many insns
Date: Thu, 19 Oct 2017 15:46:21 -0700
Message-ID: <20171019224626.31608-4-jakub.kicinski@netronome.com>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:52068 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752285AbdJSWrH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 18:47:07 -0400
Received: by mail-pf0-f193.google.com with SMTP id n14so8101535pfh.8
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 15:47:07 -0700 (PDT)
In-Reply-To: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

Make error messages and return codes more consistent. Specifically,
replace the use of info() macro with err() when too many eBPF
instructions are received to be dumped, given that bpftool returns with
a non-null exit value in that case.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 tools/bpf/bpftool/prog.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
index ede7957adcd9..6c03d2ea3f79 100644
--- a/tools/bpf/bpftool/prog.c
+++ b/tools/bpf/bpftool/prog.c
@@ -416,7 +416,7 @@ static int do_dump(int argc, char **argv)
 	}
 
 	if (*member_len > buf_size) {
-		info("too many instructions returned\n");
+		err("too many instructions returned\n");
 		goto err_free;
 	}
 
-- 
2.14.1
