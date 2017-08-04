From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v4 0/2] bpf: add support for sys_{enter|exit}_* tracepoints
Date: Fri, 4 Aug 2017 16:00:08 -0700
Message-ID: <20170804230010.2792119-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48390 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752038AbdHDXAM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 19:00:12 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v74Mx8l3032283
        for <netdev@vger.kernel.org>; Fri, 4 Aug 2017 16:00:12 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2c5011gemc-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 16:00:12 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 aafdd30e796811e79ae60002c991e86a-98cad150 for <netdev@vger.kernel.org>;        Fri,
 04 Aug 2017 16:00:11 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, bpf programs cannot be attached to sys_enter_* and sys_exit_*
style tracepoints. The main reason is that syscalls/sys_enter_* and syscalls/sys_exit_*
tracepoints are treated differently from other tracepoints and there
is no bpf hook to it.

This patch set adds bpf support for these syscalls tracepoints and also
adds a test case for it.

Changelogs:
v3 -> v4:
 - Check the legality of ctx offset access for syscall tracepoint as well.
   trace_event_get_offsets will return correct max offset for each
   specific syscall tracepoint.
 - Use variable length array to avoid hardcode 6 as the maximum
   arguments beyond syscall_nr.
v2 -> v3:
 - Fix a build issue
v1 -> v2:
 - Do not use TRACE_EVENT_FL_CAP_ANY to identify syscall tracepoint.
   Instead use trace_event_call->class.

Yonghong Song (2):
  bpf: add support for sys_enter_* and sys_exit_* tracepoints
  bpf: add a test case for syscalls/sys_{enter|exit}_* tracepoints

 include/linux/syscalls.h      | 12 ++++++++
 kernel/events/core.c          | 10 +++---
 kernel/trace/trace_syscalls.c | 53 ++++++++++++++++++++++++++++++--
 samples/bpf/Makefile          |  4 +++
 samples/bpf/syscall_tp_kern.c | 62 +++++++++++++++++++++++++++++++++++++
 samples/bpf/syscall_tp_user.c | 71 +++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 206 insertions(+), 6 deletions(-)
 create mode 100644 samples/bpf/syscall_tp_kern.c
 create mode 100644 samples/bpf/syscall_tp_user.c

-- 
2.9.4
