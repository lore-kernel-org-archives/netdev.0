From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v3 0/3] bpf: permit multiple bpf attachments for a single perf tracepoint event
Date: Mon, 23 Oct 2017 23:53:06 -0700
Message-ID: <20171024065309.2401893-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48400 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750886AbdJXGxP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 02:53:15 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9O6o3IO027963
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 23:53:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dsye005w2-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 23:53:15 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds support to permit multiple bpf prog attachments
for a single perf tracepoint event. Patch 1 does some cleanup such
that perf_event_{set|free}_bpf_handler is called under the
same condition. Patch 2 has the core implementation, and
Patch 3 adds a test case.

Changelogs:
v2 -> v3:
  . fix compilation error.
v1 -> v2:
  . fix a potential deadlock issue discovered by Daniel.
  . fix some coding style issues.

Yonghong Song (3):
  bpf: use the same condition in perf event set/free bpf handler
  bpf: permit multiple bpf attachments for a single perf event
  bpf: add a test case to test single tp multiple bpf attachment

 include/linux/bpf.h           | 30 +++++++++++++---
 include/linux/trace_events.h  | 43 ++++++++++++++++++++---
 include/trace/perf.h          |  6 ++--
 kernel/bpf/core.c             | 81 ++++++++++++++++++++++++++++++++++++++++++
 kernel/events/core.c          | 30 ++++++----------
 kernel/trace/bpf_trace.c      | 82 ++++++++++++++++++++++++++++++++++++++++---
 kernel/trace/trace_kprobe.c   |  6 ++--
 kernel/trace/trace_syscalls.c | 34 ++++++++++--------
 kernel/trace/trace_uprobe.c   |  3 +-
 samples/bpf/syscall_tp_user.c | 66 +++++++++++++++++++++++++++-------
 10 files changed, 310 insertions(+), 71 deletions(-)

-- 
2.9.5
