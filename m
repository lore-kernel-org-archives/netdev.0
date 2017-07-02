From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/7] Misc BPF helper/verifier improvements
Date: Sun,  2 Jul 2017 02:13:24 +0200
Message-ID: <cover.1498952486.git.daniel@iogearbox.net>
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57522 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752172AbdGBANn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 20:13:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellanous improvements I still had in my queue, it adds a new
bpf_skb_adjust_room() helper for cls_bpf, exports to fdinfo whether
tail call array owner is JITed, so iproute2 error reporting can be
improved on that regard, a small cleanup and extension to trace
printk, two verifier patches, one to make the code around narrower
ctx access a bit more straight forward and one to allow for imm += x
operations, that we've seen LLVM generating and the verifier currently
rejecting. We've included the patch 6 given it's rather small and
we ran into it from LLVM side, it would be great if it could be
queued for stable as well after the merge window. Last but not least,
test cases are added also related to imm alu improvement.

Thanks a lot!

Daniel Borkmann (5):
  bpf, net: add skb_mac_header_len helper
  bpf: add bpf_skb_adjust_room helper
  bpf: simplify narrower ctx access
  bpf: export whether tail call has jited owner
  bpf: add various test cases for verifier selftest

John Fastabend (2):
  bpf: extend bpf_trace_printk to support %i
  bpf, verifier: add additional patterns to evaluate_reg_imm_alu

 include/linux/bpf.h                         |   9 +-
 include/linux/filter.h                      |  47 ++++
 include/linux/skbuff.h                      |   5 +
 include/uapi/linux/bpf.h                    |  16 +-
 kernel/bpf/syscall.c                        |   7 +-
 kernel/bpf/verifier.c                       | 140 +++++++----
 kernel/trace/bpf_trace.c                    |  38 ++-
 net/core/filter.c                           | 369 +++++++++++++++++-----------
 tools/include/uapi/linux/bpf.h              |  16 +-
 tools/testing/selftests/bpf/test_verifier.c | 165 +++++++++++++
 10 files changed, 604 insertions(+), 208 deletions(-)

-- 
1.9.3
