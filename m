From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v3 net-next 0/7] bpf: Add option to set mark and priority in cgroup sock programs
Date: Thu, 31 Aug 2017 15:05:43 -0700
Message-ID: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38399 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdHaWGJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 18:06:09 -0400
Received: by mail-pf0-f194.google.com with SMTP id r187so518455pfr.5
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 15:06:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add option to set mark and priority in addition to bound device for newly
created sockets. Also, allow the bpf programs to use the get_current_uid_gid
helper meaning socket marks, priority and device can be set based on the
uid/gid of the running process.

Sample programs are updated to demonstrate the new options.

v3
- no changes to Patches 1 and 2 which Alexei acked in previous versions
- dropped change related to recursive programs in a cgroup
- updated tests per dropped patch

v2
- added flag to control recursive behavior as requested by Alexei
- added comment to sock_filter_func_proto regarding use of
  get_current_uid_gid helper
- updated test programs for recursive option

David Ahern (7):
  bpf: Add mark and priority to sock options that can be set
  bpf: Allow cgroup sock filters to use get_current_uid_gid helper
  samples/bpf: Update sock test to allow setting mark and priority
  samples/bpf: Add detach option to test_cgrp2_sock
  samples/bpf: Add option to dump socket settings
  samples/bpf: Update cgrp2 socket tests
  samples/bpf: Update cgroup socket examples to use uid gid helper

 include/uapi/linux/bpf.h       |   2 +
 net/core/filter.c              |  42 ++++++-
 samples/bpf/sock_flags_kern.c  |   5 +
 samples/bpf/test_cgrp2_sock.c  | 255 ++++++++++++++++++++++++++++++++++++-----
 samples/bpf/test_cgrp2_sock.sh | 162 ++++++++++++++++++++------
 5 files changed, 401 insertions(+), 65 deletions(-)

-- 
2.1.4
