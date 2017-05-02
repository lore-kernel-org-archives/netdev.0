From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/4] Improve bpf ELF-loader under samples/bpf
Date: Tue, 02 May 2017 14:31:45 +0200
Message-ID: <149372826543.22268.3617359219409721129.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21476 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750886AbdEBMcE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 08:32:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series improves and fixes bpf ELF loader and programs under
samples/bpf.  The bpf_load.c created some hard to debug issues when
the struct (bpf_map_def) used in the ELF maps section format changed
in commit fb30d4b71214 ("bpf: Add tests for map-in-map").

This was hotfixed in commit 409526bea3c3 ("samples/bpf: bpf_load.c
detect and abort if ELF maps section size is wrong") by detecting the
issue and aborting the program.

In most situations the bpf-loader should be able to handle these kind
of changes to the struct size.  This patch series aim to do proper
backward and forward compabilility handling when loading ELF files.

This series also adjust the callback that was introduced in commit
9fd63d05f3e8 ("bpf: Allow bpf sample programs (*_user.c) to change
bpf_map_def") to use the new bpf_map_data structure, before more users
start to use this callback.

Hoping these changes can make the merge window, as above mentioned
commits have not been merged yet, and it would be good to avoid users
hitting these issues.

---

Jesper Dangaard Brouer (4):
      samples/bpf: adjust rlimit RLIMIT_MEMLOCK for traceex2, tracex3 and tracex4
      samples/bpf: make bpf_load.c code compatible with ELF maps section changes
      samples/bpf: load_bpf.c make callback fixup more flexible
      samples/bpf: export map_data[] for more info on maps


 samples/bpf/bpf_load.c           |  229 ++++++++++++++++++++++++++------------
 samples/bpf/bpf_load.h           |   18 ++-
 samples/bpf/map_perf_test_user.c |   14 +-
 samples/bpf/tracex2_user.c       |    7 +
 samples/bpf/tracex3_user.c       |    7 +
 samples/bpf/tracex4_user.c       |    8 +
 6 files changed, 201 insertions(+), 82 deletions(-)
