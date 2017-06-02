From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v3 net-next 0/3] bpf: Add BPF support to all perf_event
Date: Thu, 1 Jun 2017 19:03:33 -0700
Message-ID: <20170602020336.1062853-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41909 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751122AbdFBCDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 22:03:39 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v521xl0m009699
        for <netdev@vger.kernel.org>; Thu, 1 Jun 2017 19:03:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2atutu8jrx-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 19:03:39 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 b115fd38473711e7a6106900506838e1-7ef358f0 for <netdev@vger.kernel.org>;        Thu,
 01 Jun 2017 19:03:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2->v3: more refactoring to address Peter's feedback.
Now all perf_events are attachable and readable

v1->v2: address Peter's feedback. Refactor patch 1 to allow attaching
bpf programs to all event types and reading counters from all of them as well
patch 2 - more tests
patch 3 - address Dave's feedback and document bpf_perf_event_read()
and bpf_perf_event_output() properly

Alexei Starovoitov (1):
  perf, bpf: Add BPF support to all perf_event types

Teng Qin (2):
  samples/bpf: add tests for more perf event types
  bpf: update perf event helper functions documentation

 include/linux/perf_event.h     |   7 +-
 include/uapi/linux/bpf.h       |  11 ++-
 kernel/bpf/arraymap.c          |  29 +------
 kernel/events/core.c           |  47 ++++++-----
 kernel/trace/bpf_trace.c       |  21 ++---
 samples/bpf/bpf_helpers.h      |   3 +-
 samples/bpf/trace_event_user.c |  73 ++++++++++++++---
 samples/bpf/tracex6_kern.c     |  28 +++++--
 samples/bpf/tracex6_user.c     | 180 ++++++++++++++++++++++++++++++++---------
 tools/include/uapi/linux/bpf.h |  11 ++-
 10 files changed, 287 insertions(+), 123 deletions(-)

-- 
2.9.3
