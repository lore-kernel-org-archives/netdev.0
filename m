From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 0/5] Various BPF fixes
Date: Thu, 25 May 2017 01:05:04 +0200
Message-ID: <cover.1495665905.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40295 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031593AbdEXXFa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 19:05:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up to fix incorrect pruning when alignment tracking is
in use and to properly clear regs after call to not leave stale
data behind, also a fix that adds bpf_clone_redirect to the
bpf_helper_changes_pkt_data helper and exposes correct map_flags
for lpm map into fdinfo. For details, please see individual
patches.

Thanks!

v1 -> v2:
  - Reworked first patch so that env->strict_alignment is the
    final indicator on whether we have to deal with strict
    alignment rather than having CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
    checks on various locations, so only checking env->strict_alignment
    is sufficient after that. Thanks for spotting, Dave!
  - Added patch 3 and 4.
  - Rest as is.

Daniel Borkmann (5):
  bpf: fix incorrect pruning decision when alignment must be tracked
  bpf: properly reset caller saved regs after helper call and ld_abs/ind
  bpf: add bpf_clone_redirect to bpf_helper_changes_pkt_data
  bpf: fix wrong exposure of map_flags into fdinfo for lpm
  bpf: add various verifier test cases

 include/linux/filter.h                      |  10 ++
 kernel/bpf/arraymap.c                       |   1 +
 kernel/bpf/lpm_trie.c                       |   1 +
 kernel/bpf/stackmap.c                       |   1 +
 kernel/bpf/verifier.c                       |  56 +++----
 net/core/filter.c                           |   1 +
 tools/include/linux/filter.h                |  10 ++
 tools/testing/selftests/bpf/test_verifier.c | 239 +++++++++++++++++++++++++++-
 8 files changed, 285 insertions(+), 34 deletions(-)

-- 
1.9.3
