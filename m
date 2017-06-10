From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/8] Misc BPF updates
Date: Sun, 11 Jun 2017 00:50:39 +0200
Message-ID: <cover.1497133948.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57815 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751660AbdFJWu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 18:50:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set contains a couple of misc updates: stack usage reduction
for perf_sample_data in tracing progs, reduction of stale data in
verifier on register state transitions that I still had in my queue
and few selftest improvements as well as bpf_set_hash() helper for
tc programs.

Thanks!

Daniel Borkmann (8):
  bpf: avoid excessive stack usage for perf_sample_data
  bpf: don't check spilled reg state for non-STACK_SPILLed type slots
  bpf: reset id on CONST_IMM transition
  bpf: reset id on spilled regs in clear_all_pkt_pointers
  bpf, tests: add a test for htab lookup + update traversal
  bpf, tests: set rlimit also for test_align, so it doesn't fail
  bpf: remove cg_skb_func_proto and use sk_filter_func_proto directly
  bpf: add bpf_set_hash helper for tc progs

 include/uapi/linux/bpf.h                 |  8 ++++-
 kernel/bpf/verifier.c                    |  8 +++--
 kernel/trace/bpf_trace.c                 | 10 ++++---
 net/core/filter.c                        | 28 +++++++++++++-----
 tools/include/uapi/linux/bpf.h           |  8 ++++-
 tools/testing/selftests/bpf/test_align.c |  5 ++++
 tools/testing/selftests/bpf/test_maps.c  | 50 ++++++++++++++++++++++++++++++++
 7 files changed, 102 insertions(+), 15 deletions(-)

-- 
1.9.3
