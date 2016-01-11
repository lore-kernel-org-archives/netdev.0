From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 0/9] bpf: support percpu ARRAY map
Date: Mon, 11 Jan 2016 23:56:52 +0800
Message-ID: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In case of ARRAY map, the index of the array is used as key
of the map, then inevitably the mapped element/value can be
accessed from more than one CPU concurrently, so expensive
atomic operations are often required in eBPF prog. And we can
see these usages in tracex3, sockex1 and sockex3 in sample/bpf/
of kernel tree.

This patchset trys to introduce percpu ARRAY map to address
the issue.

The 1st two patches prepares for supporting percpu map, and
introduces one file to hold the map common functions.

The following 3 patches introdues percpu version of update/
lookup element in bpf_map_ops, bpf helpers and syscall, so
that percpu value can be retrieved/updated from eBPF prog
and syscall. 

The 6th patch implements percpu array map.

The last 3 patches are changes in samples/bpf, and implements
test for perpcu array and converts to percpu array in sockex1
exmaple.

 include/linux/bpf.h        |  10 ++++
 include/uapi/linux/bpf.h   |  10 ++++
 kernel/bpf/Makefile        |   2 +-
 kernel/bpf/arraymap.c      | 153 +++++++++++++++++++++++++++++++++++++++++++++++++++---------
 kernel/bpf/bpf_map.h       |  15 ++++++
 kernel/bpf/core.c          |   2 +
 kernel/bpf/hashtab.c       |   4 ++
 kernel/bpf/helpers.c       |  53 +++++++++++++++++++++
 kernel/bpf/map.c           |  43 +++++++++++++++++
 kernel/bpf/syscall.c       |  48 +++++++++++++++----
 net/core/filter.c          |   4 ++
 samples/bpf/bpf_helpers.h  |   5 ++
 samples/bpf/libbpf.c       |  42 +++++++++++++++++
 samples/bpf/libbpf.h       |   5 ++
 samples/bpf/sockex1_kern.c |   7 +--
 samples/bpf/sockex1_user.c |  20 ++++++--
 samples/bpf/test_maps.c    | 110 +++++++++++++++++++++++++++++++++++++++++++
 17 files changed, 493 insertions(+), 40 deletions(-)



thanks,
Ming
