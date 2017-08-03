From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v3 0/2] bpf: add support for sys_{enter|exit}_* tracepoints
Date: Thu, 3 Aug 2017 09:29:49 -0700
Message-ID: <20170803162951.1564963-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44544 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751211AbdHCQ3y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:29:54 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v73GQt5c030465
        for <netdev@vger.kernel.org>; Thu, 3 Aug 2017 09:29:54 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2c3r24ukba-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 09:29:54 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 f9ecb116786811e7af7f858c2141f014-a77c1150 for <netdev@vger.kernel.org>;        Thu,
 03 Aug 2017 09:29:52 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, bpf programs cannot be attached to sys_enter_* and sys_exit_*
style tracepoints. The main reason is that syscalls/sys_enter_* and syscalls/sys_exit_*
tracepoints are treated differently from other tracepoints and there
is no bpf hook to it.

This patch set adds bpf support for these syscalls tracepoints and also
adds a test case for it.

Changes from v2:
 - Fix a build issue
Changes from v1:
 - Do not use TRACE_EVENT_FL_CAP_ANY to identify syscall tracepoint.
   Instead use trace_event_call->class.

Yonghong Song (2):
  bpf: add support for sys_enter_* and sys_exit_* tracepoints
  bpf: add a test case for syscalls/sys_{enter|exit}_* tracepoints

 include/linux/syscalls.h      | 12 ++++++++
 kernel/events/core.c          |  8 +++--
 kernel/trace/trace_syscalls.c | 53 ++++++++++++++++++++++++++++++--
 samples/bpf/Makefile          |  4 +++
 samples/bpf/syscall_tp_kern.c | 62 +++++++++++++++++++++++++++++++++++++
 samples/bpf/syscall_tp_user.c | 71 +++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 205 insertions(+), 5 deletions(-)
 create mode 100644 samples/bpf/syscall_tp_kern.c
 create mode 100644 samples/bpf/syscall_tp_user.c

-- 
2.9.4
