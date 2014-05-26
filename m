From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: filter: test fill/spill of all M[] regs
Date: Mon, 26 May 2014 20:17:34 +0200
Message-ID: <1401128255-6545-2-git-send-email-dborkman@redhat.com>
References: <1401128255-6545-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991AbaEZSRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2014 14:17:42 -0400
In-Reply-To: <1401128255-6545-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This test for classic BPF probes stores and load combination
via X on all 16 registers of the scratch memory store. It
initially loads integer 100 and passes this value around
to each register while incrementing it every time, thus we
expect to have 116 as a result. Might be useful for JIT
testing.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 lib/test_bpf.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 90 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index af677cb..6be9119 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1485,6 +1485,96 @@ static struct bpf_test tests[] = {
 		{ },
 		{ },
 	},
+	{	/* Mainly checking JIT here. */
+		"M[]: STX + LDX",
+		.u.insns = {
+			BPF_STMT(BPF_LDX | BPF_IMM, 100),
+			BPF_STMT(BPF_STX, 0),
+			BPF_STMT(BPF_LDX | BPF_MEM, 0),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 1),
+			BPF_STMT(BPF_LDX | BPF_MEM, 1),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 2),
+			BPF_STMT(BPF_LDX | BPF_MEM, 2),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 3),
+			BPF_STMT(BPF_LDX | BPF_MEM, 3),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 4),
+			BPF_STMT(BPF_LDX | BPF_MEM, 4),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 5),
+			BPF_STMT(BPF_LDX | BPF_MEM, 5),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 6),
+			BPF_STMT(BPF_LDX | BPF_MEM, 6),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 7),
+			BPF_STMT(BPF_LDX | BPF_MEM, 7),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 8),
+			BPF_STMT(BPF_LDX | BPF_MEM, 8),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 9),
+			BPF_STMT(BPF_LDX | BPF_MEM, 9),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 10),
+			BPF_STMT(BPF_LDX | BPF_MEM, 10),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 11),
+			BPF_STMT(BPF_LDX | BPF_MEM, 11),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 12),
+			BPF_STMT(BPF_LDX | BPF_MEM, 12),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 13),
+			BPF_STMT(BPF_LDX | BPF_MEM, 13),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 14),
+			BPF_STMT(BPF_LDX | BPF_MEM, 14),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_STX, 15),
+			BPF_STMT(BPF_LDX | BPF_MEM, 15),
+			BPF_STMT(BPF_MISC | BPF_TXA, 0),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 1),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_RET | BPF_A, 0),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{ },
+		{ { 0, 116 } },
+	},
 };
 
 static struct net_device dev;
-- 
1.7.11.7
