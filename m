From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: bpf: fix compiler warnings in test_bpf
Date: Fri, 19 Sep 2014 13:53:51 -0700
Message-ID: <1411160031-3538-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:57988 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932297AbaISUyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:54:00 -0400
Received: by mail-pd0-f179.google.com with SMTP id ft15so636602pdb.10
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 13:53:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

old gcc 4.2 used by avr32 architecture produces warnings:

lib/test_bpf.c:1741: warning: integer constant is too large for 'long' type
lib/test_bpf.c:1741: warning: integer constant is too large for 'long' type
lib/test_bpf.c: In function '__run_one':
lib/test_bpf.c:1897: warning: 'ret' may be used uninitialized in this function

silence these warnings.

Fixes: 02ab695bb37e ("net: filter: add "load 64-bit immediate" eBPF instruction")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 lib/test_bpf.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 413890815d3e..23e070bcf72d 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1738,7 +1738,7 @@ static struct bpf_test tests[] = {
 	{
 		"load 64-bit immediate",
 		.u.insns_int = {
-			BPF_LD_IMM64(R1, 0x567800001234L),
+			BPF_LD_IMM64(R1, 0x567800001234LL),
 			BPF_MOV64_REG(R2, R1),
 			BPF_MOV64_REG(R3, R2),
 			BPF_ALU64_IMM(BPF_RSH, R2, 32),
@@ -1894,7 +1894,7 @@ static int __run_one(const struct bpf_prog *fp, const void *data,
 		     int runs, u64 *duration)
 {
 	u64 start, finish;
-	int ret, i;
+	int ret = 0, i;
 
 	start = ktime_to_us(ktime_get());
 
-- 
1.7.9.5
