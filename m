From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 0/8] bpf: Add option to set mark and priority in cgroup sock programs
Date: Tue, 22 Aug 2017 17:20:13 -0700
Message-ID: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33638 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752774AbdHWAU3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 20:20:29 -0400
Received: by mail-pg0-f66.google.com with SMTP id u191so226853pgc.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 17:20:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add option to set mark and priority in addition to bound device for newly
created sockets. Also, allow the bpf programs to use the get_current_uid_gid
helper meaning socket marks, priority and device can be set base on the
uid/gid of the running process.

For flexbility in deploying these programs, cgroups are walked from
current to root running any program attached. This allows one cgroup
level to control the device a socket is bound to (e.g, a VRF) while
cgroups can be used to set socket marks and priority.

Sample programs are updated to demonstrate the new options.

David Ahern (8):
  bpf: Recursively apply cgroup sock filters
  bpf: Add mark and priority to sock options that can be set
  bpf: Allow cgroup sock filters to use get_current_uid_gid helper
  bpf samples: Update sock test to allow setting mark and priority
  bpf/samples: Add detach option to test_cgrp2_sock
  samples/bpf: Add option to dump socket settings
  samples/bpf: Add test case for nested socket options
  samples/bpf: Update cgroup socket examples to use uid gid helper

 include/linux/bpf-cgroup.h      |   5 +-
 include/uapi/linux/bpf.h        |   2 +
 kernel/bpf/cgroup.c             |   4 +-
 kernel/cgroup/cgroup.c          |  18 +++
 net/core/filter.c               |  39 ++++++-
 samples/bpf/sock_flags_kern.c   |   5 +
 samples/bpf/test_cgrp2_sock.c   | 252 ++++++++++++++++++++++++++++++++++++----
 samples/bpf/test_cgrp2_sock.sh  |   2 +-
 samples/bpf/test_cgrp2_sock3.sh | 118 +++++++++++++++++++
 9 files changed, 413 insertions(+), 32 deletions(-)
 create mode 100755 samples/bpf/test_cgrp2_sock3.sh

-- 
2.1.4
