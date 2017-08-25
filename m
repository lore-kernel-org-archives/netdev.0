From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 0/8] bpf: Add option to set mark and priority in cgroup sock programs
Date: Fri, 25 Aug 2017 12:05:33 -0700
Message-ID: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:38012 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755040AbdHYTFt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 15:05:49 -0400
Received: by mail-pg0-f68.google.com with SMTP id t3so880172pgt.5
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 12:05:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add option to set mark and priority in addition to bound device for newly
created sockets. Also, allow the bpf programs to use the get_current_uid_gid
helper meaning socket marks, priority and device can be set base on the
uid/gid of the running process.

For flexbility in deploying these programs, option is added to allow cgroups
to be walked from current to root running any program attached. This allows
one cgroup level to control the device a socket is bound to (e.g, a VRF) while
cgroups can be used to set socket marks and priority.

Sample programs are updated to demonstrate the new options.

v2
- added flag to control recursive behavior as requested by Alexei
- added comment to sock_filter_func_proto regarding use of
  get_current_uid_gid helper
- updated test programs for recursive option

David Ahern (8):
  bpf: Add support for recursively running cgroup sock filters
  bpf: Add mark and priority to sock options that can be set
  bpf: Allow cgroup sock filters to use get_current_uid_gid helper
  samples/bpf: Update sock test to allow setting mark and priority
  samples/bpf: Add detach option to test_cgrp2_sock
  samples/bpf: Add option to dump socket settings
  samples/bpf: Add test case for nested socket options
  samples/bpf: Update cgroup socket examples to use uid gid helper

 include/linux/bpf-cgroup.h      |  10 +-
 include/uapi/linux/bpf.h        |  11 ++
 kernel/bpf/cgroup.c             |  29 +++--
 kernel/bpf/syscall.c            |   6 +-
 kernel/cgroup/cgroup.c          |  25 +++-
 net/core/filter.c               |  42 ++++++-
 samples/bpf/sock_flags_kern.c   |   5 +
 samples/bpf/test_cgrp2_sock.c   | 258 ++++++++++++++++++++++++++++++++++++----
 samples/bpf/test_cgrp2_sock.sh  |   2 +-
 samples/bpf/test_cgrp2_sock3.sh | 162 +++++++++++++++++++++++++
 10 files changed, 506 insertions(+), 44 deletions(-)
 create mode 100755 samples/bpf/test_cgrp2_sock3.sh

-- 
2.1.4
