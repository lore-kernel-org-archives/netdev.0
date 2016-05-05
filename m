From: Colin King <colin.king@canonical.com>
Subject: [PATCH] tools: bpf_jit_disasm: check for klogctl failure
Date: Thu,  5 May 2016 23:39:33 +0100
Message-ID: <1462487973-21712-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

klogctl can fail and return -ve len, so check for this and
return NULL to avoid passing a (size_t)-1 to malloc.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 tools/net/bpf_jit_disasm.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tools/net/bpf_jit_disasm.c b/tools/net/bpf_jit_disasm.c
index 5b32413..544b05a 100644
--- a/tools/net/bpf_jit_disasm.c
+++ b/tools/net/bpf_jit_disasm.c
@@ -98,6 +98,9 @@ static char *get_klog_buff(unsigned int *klen)
 	char *buff;
 
 	len = klogctl(CMD_ACTION_SIZE_BUFFER, NULL, 0);
+	if (len < 0)
+		return NULL;
+
 	buff = malloc(len);
 	if (!buff)
 		return NULL;
-- 
2.8.1
