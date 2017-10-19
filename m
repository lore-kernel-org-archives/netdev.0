From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/8] tools: bpftool: fix return value when all eBPF programs have been shown
Date: Thu, 19 Oct 2017 15:46:20 -0700
Message-ID: <20171019224626.31608-3-jakub.kicinski@netronome.com>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:50668 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752976AbdJSWrF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 18:47:05 -0400
Received: by mail-pf0-f194.google.com with SMTP id b6so8104968pfh.7
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 15:47:05 -0700 (PDT)
In-Reply-To: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

Change the program to have a more consistent return code. Specifically,
do not make bpftool return an error code simply because it reaches the
end of the list of the eBPF programs to show.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 tools/bpf/bpftool/prog.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
index aa6d72ea3807..ede7957adcd9 100644
--- a/tools/bpf/bpftool/prog.c
+++ b/tools/bpf/bpftool/prog.c
@@ -275,8 +275,10 @@ static int do_show(int argc, char **argv)
 	while (true) {
 		err = bpf_prog_get_next_id(id, &id);
 		if (err) {
-			if (errno == ENOENT)
+			if (errno == ENOENT) {
+				err = 0;
 				break;
+			}
 			err("can't get next program: %s\n", strerror(errno));
 			if (errno == EINVAL)
 				err("kernel too old?\n");
-- 
2.14.1
