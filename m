From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next] test: bpf: expand DIV_KX to DIV_MOD_KX
Date: Mon,  1 Dec 2014 13:12:25 +0300
Message-ID: <1417428745-20199-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>,
	Alexei Starovoitov <ast@plumgrid.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:51420 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596AbaLAKQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 05:16:08 -0500
Received: by mail-la0-f52.google.com with SMTP id hs14so3681064lab.39
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 02:16:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expand DIV_KX to use BPF_MOD operation in the
DIV_KX bpf 'classic' test.

CC: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 lib/test_bpf.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 3f167d2..80d78c5 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -124,7 +124,7 @@ static struct bpf_test tests[] = {
 		{ { 0, 0xfffffffd } }
 	},
 	{
-		"DIV_KX",
+		"DIV_MOD_KX",
 		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, 8),
 			BPF_STMT(BPF_ALU | BPF_DIV | BPF_K, 2),
@@ -134,12 +134,18 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_MISC | BPF_TAX, 0),
 			BPF_STMT(BPF_LD | BPF_IMM, 0xffffffff),
 			BPF_STMT(BPF_ALU | BPF_DIV | BPF_K, 0x70000000),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_LD | BPF_IMM, 0xffffffff),
+			BPF_STMT(BPF_ALU | BPF_MOD | BPF_X, 0),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0),
+			BPF_STMT(BPF_LD | BPF_IMM, 0xffffffff),
+			BPF_STMT(BPF_ALU | BPF_MOD | BPF_K, 0x70000000),
 			BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
 		CLASSIC | FLAG_NO_DATA,
 		{ },
-		{ { 0, 0x40000001 } }
+		{ { 0, 0x20000000 } }
 	},
 	{
 		"AND_OR_LSH_K",
-- 
1.7.10.4
