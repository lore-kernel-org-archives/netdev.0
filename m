From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 net-next 0/2] bpf/verifier: disassembly improvements
Date: Tue, 26 Sep 2017 16:32:15 +0100
Message-ID: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <daniel@iogearbox.net>,
        <alexei.starovoitov@gmail.com>, <ys114321@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:32929 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1030485AbdIZPc0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 11:32:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the output of print_bpf_insn() for ALU ops that don't look like
 compound assignment (i.e. BPF_END and BPF_NEG).

Sample output for a short test program:
0: (b4) (u32) r0 = (u32) 0
1: (dc) r0 = be32 r0
2: (84) r0 = (u32) -r0
3: (95) exit
processed 4 insns, stack depth 0

Edward Cree (2):
  bpf/verifier: improve disassembly of BPF_END instructions
  bpf/verifier: improve disassembly of BPF_NEG instructions

 kernel/bpf/verifier.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)
