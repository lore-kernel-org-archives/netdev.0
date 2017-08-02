From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next 0/2] bpf: add support for sys_{enter|exit}_* tracepoints
Date: Tue, 1 Aug 2017 23:30:03 -0700
Message-ID: <20170802063005.3220186-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <ast@fb.com>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37384 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751066AbdHBGaH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 02:30:07 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v726TvbT006706
        for <netdev@vger.kernel.org>; Tue, 1 Aug 2017 23:30:06 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2c36ktgnhm-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 23:30:06 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 05ea37ae774c11e79c790002c9dfb610-202d7150 for <netdev@vger.kernel.org>;        Tue,
 01 Aug 2017 23:30:05 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, bpf programs cannot be attached to sys_enter_* and sys_exit_*
style tracepoints. The main reason is that syscalls/sys_enter_* and syscalls/sys_exit_*
tracepoints are treated differently from other tracepoints and there
is no bpf hook to it.

This patch set adds bpf support for these syscalls tracepoints and also
adds a test case for it.

Yonghong Song (2):
  bpf: add support for sys_enter_* and sys_exit_* tracepoints
  bpf: add a test case for syscalls/sys_{enter|exit}_* tracepoints

 kernel/events/core.c          |  9 ++++--
 kernel/trace/trace_syscalls.c | 53 ++++++++++++++++++++++++++++++--
 samples/bpf/Makefile          |  4 +++
 samples/bpf/syscall_tp_kern.c | 62 +++++++++++++++++++++++++++++++++++++
 samples/bpf/syscall_tp_user.c | 71 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 194 insertions(+), 5 deletions(-)
 create mode 100644 samples/bpf/syscall_tp_kern.c
 create mode 100644 samples/bpf/syscall_tp_user.c

-- 
2.9.4
