From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 0/3] bpf: Add BPF support to all perf_event
Date: Thu, 25 May 2017 22:55:46 -0700
Message-ID: <20170526055549.557818-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39426 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S966040AbdEZFzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 01:55:52 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v4Q5q6Ng012366
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 22:55:51 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2ap87prsye-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 22:55:51 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 f879798041d711e7a4e10002c99293a0-6bf398f0 for <netdev@vger.kernel.org>;        Thu,
 25 May 2017 22:55:50 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2: address Peter's feedback. Refactor patch 1 to allow attaching
bpf programs to all event types and reading counters from all of them as well
patch 2 - more tests
patch 3 - address Dave's feedback and document bpf_perf_event_read()
and bpf_perf_event_output() properly

Teng Qin (3):
  perf, bpf: Add BPF support to all perf_event types
  samples/bpf: add samples for more perf event types
  bpf: update perf event helper functions documentation

 include/uapi/linux/bpf.h       |  11 ++-
 kernel/bpf/arraymap.c          |  26 +++---
 kernel/events/core.c           |   6 +-
 kernel/trace/bpf_trace.c       |   4 +-
 samples/bpf/bpf_helpers.h      |   3 +-
 samples/bpf/trace_event_user.c |  46 ++++++++++-
 samples/bpf/tracex6_kern.c     |  28 +++++--
 samples/bpf/tracex6_user.c     | 176 ++++++++++++++++++++++++++++++++---------
 tools/include/uapi/linux/bpf.h |  11 ++-
 9 files changed, 232 insertions(+), 79 deletions(-)

-- 
2.9.3
