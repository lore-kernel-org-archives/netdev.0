From: Wei Tang <tangwei@cmss.chinamobile.com>
Subject: [PATCH] bpf_dbg: do not initialise statics to 0
Date: Thu,  4 Feb 2016 17:36:23 +0800
Message-ID: <1454578583-4722-1-git-send-email-tangwei@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, Wei Tang <tangwei@cmss.chinamobile.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from n9-28.mail.139.com ([221.176.9.28]:38329 "EHLO
	n9-28.mail.139.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755960AbcBDJpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 04:45:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the checkpatch.pl error to bpf_dbg.c:

ERROR: do not initialise statics to 0

Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>
---
 tools/net/bpf_dbg.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/net/bpf_dbg.c b/tools/net/bpf_dbg.c
index 9a287be..4f254bc 100644
--- a/tools/net/bpf_dbg.c
+++ b/tools/net/bpf_dbg.c
@@ -129,16 +129,16 @@ struct bpf_regs {
 };
 
 static struct sock_filter bpf_image[BPF_MAXINSNS + 1];
-static unsigned int bpf_prog_len = 0;
+static unsigned int bpf_prog_len;
 
 static int bpf_breakpoints[64];
 static struct bpf_regs bpf_regs[BPF_MAXINSNS + 1];
 static struct bpf_regs bpf_curr;
-static unsigned int bpf_regs_len = 0;
+static unsigned int bpf_regs_len;
 
 static int pcap_fd = -1;
-static unsigned int pcap_packet = 0;
-static size_t pcap_map_size = 0;
+static unsigned int pcap_packet;
+static size_t pcap_map_size;
 static char *pcap_ptr_va_start, *pcap_ptr_va_curr;
 
 static const char * const op_table[] = {
@@ -1172,7 +1172,7 @@ static int cmd_breakpoint(char *subcmd)
 
 static int cmd_run(char *num)
 {
-	static uint32_t pass = 0, fail = 0;
+	static uint32_t pass, fail;
 	bool has_limit = true;
 	int pkts = 0, i = 0;
 
-- 
1.9.1
