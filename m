From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/3] BPF testsuite and cleanup
Date: Thu,  8 May 2014 14:10:50 -0700
Message-ID: <1399583453-4315-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:63620 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921AbaEHVLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 17:11:01 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so3337960pab.8
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 14:11:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds BPF testsuite and improves readability of classic
to internal BPF converter.

The testsuite helped to find 'negative offset bug' in x64 JIT that was
fixed by commit fdfaf64e ("x86: bpf_jit: support negative offsets")

It can be very useful for classic and internal JIT compiler developers.
Also it serves as performance benchmark.

x86_64/i386 pass all tests with and without JIT. arm32 JIT is failing
negative offset tests which are unsupported.

Internal BPF tests are much larger than classic tests to cover different
combinations of registers. Negative tests check correctness of classic
BPF verifier which must reject them.

Alexei Starovoitov (3):
  net: filter: make BPF conversion more readable
  net: filter: BPF testsuite
  net: filter: additional BPF tests

 include/linux/filter.h               |   51 ++
 lib/Kconfig.debug                    |   13 +
 lib/Makefile                         |    1 +
 lib/test_bpf.c                       | 1546 ++++++++++++++++++++++++++++++++++
 net/core/filter.c                    |  142 ++--
 tools/testing/selftests/net/Makefile |    8 +-
 6 files changed, 1668 insertions(+), 93 deletions(-)
 create mode 100644 lib/test_bpf.c

-- 
1.7.9.5
