From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/4] bpf: verifier fixes
Date: Tue, 22 Aug 2017 14:17:44 +0100
Message-ID: <f25f46bd-27cb-2182-2551-2887757c1e0f@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:47109 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932657AbdHVNSC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 09:18:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a couple of bugs introduced in my recent verifier patches.
Patch #3 does slightly increase the insn count on bpf_lxc.o, but only by
 about a hundred insns (i.e. 0.2%).

Alexei Starovoitov (1):
  selftests/bpf: add a test for a pruning bug in the verifier

Edward Cree (3):
  bpf/verifier: remove varlen_map_value_access flag
  bpf/verifier: when pruning a branch, ignore its write marks
  bpf/verifier: document liveness analysis

 include/linux/bpf_verifier.h                | 14 +++++-
 kernel/bpf/verifier.c                       | 78 +++++++++++++++++------------
 tools/testing/selftests/bpf/test_verifier.c | 28 +++++++++++
 3 files changed, 87 insertions(+), 33 deletions(-)
