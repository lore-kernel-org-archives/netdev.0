From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 0/6] Libbpf object pinning
Date: Thu, 26 Jan 2017 13:19:55 -0800
Message-ID: <20170126212001.14103-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:51691 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753510AbdAZVUS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 16:20:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds pinning functionality for maps, programs, and objects.
Library users may call bpf_map__pin(map, path) or bpf_program__pin(prog, path)
to pin maps and programs separately, or use bpf_object__pin(obj, path) to
pin all maps and programs from the BPF object to the path. The map and program
variations require a path where it will be pinned in the filesystem,
and the object variation will create named directories for each program with
instances within, and mount the maps by name under the path.

For example, with the directory '/sys/fs/bpf/foo' and a BPF object which
contains two instances of a program named 'bar', and a map named 'baz':
/sys/fs/bpf/foo/bar/0
/sys/fs/bpf/foo/bar/1
/sys/fs/bpf/foo/baz

---
v3: Split out bpf_program__pin_instance().
    Change the paths from PATH/{maps,progs}/foo to the above.
    Drop the patches that were applied.
    Add a perf test to check that pinning works.
v2: Wang Nan provided improvements to patch 1.
    Dropped patch 2 from v1.
    Added acks for acked patches.
    Split the bpf_obj__pin() to also provide map / program pinning APIs.
    Allow users to provide full filesystem path (don't autodetect/mount BPFFS).
v1: Initial post.

Joe Stringer (6):
  tools lib bpf: Add BPF program pinning APIs.
  tools lib bpf: Add bpf_map__pin()
  tools lib bpf: Add bpf_object__pin()
  tools perf util: Make rm_rf(path) argument const
  tools lib api fs: Add bpf_fs filesystem detector
  perf test: Add libbpf pinning test

 tools/lib/api/fs/fs.c  |  16 +++++
 tools/lib/api/fs/fs.h  |   1 +
 tools/lib/bpf/libbpf.c | 188 +++++++++++++++++++++++++++++++++++++++++++++++++
 tools/lib/bpf/libbpf.h |   5 ++
 tools/perf/tests/bpf.c |  42 ++++++++++-
 tools/perf/util/util.c |   2 +-
 tools/perf/util/util.h |   2 +-
 7 files changed, 253 insertions(+), 3 deletions(-)

-- 
2.11.0
