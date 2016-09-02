From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v3 net-next 0/6] perf, bpf: add support for bpf in sw/hw perf_events
Date: Thu, 1 Sep 2016 18:37:20 -0700
Message-ID: <1472780246-323814-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37416 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750989AbcIBBh2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 21:37:28 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u821XIH6011243
        for <netdev@vger.kernel.org>; Thu, 1 Sep 2016 18:37:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 256uyaa048-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 18:37:27 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 ce26c64870ad11e6b3680002c9dfb610-1a4d5a50 for <netdev@vger.kernel.org>;        Thu,
 01 Sep 2016 18:37:27 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter, Dave,

this patch set is a follow up to the discussion:
https://lkml.kernel.org/r/20160804142853.GO6862%20()%20twins%20!%20programming%20!%20kicks-ass%20!%20net
It turned out to be simpler than what we discussed.

Patches 1-3 is bpf-side prep for the main patch 4
that adds bpf program as an overflow_handler to sw and hw perf_events.

Patches 5 and 6 are examples from myself and Brendan.

Peter,
to implement your suggestion to add ifdef CONFIG_BPF_SYSCALL
inside struct perf_event, I had to shuffle ifdefs in events/core.c
Please double check whether that is what you wanted to see.

v2->v3: fixed few more minor issues
v1->v2: fixed issues spotted by Peter and Daniel.

Thanks!

Alexei Starovoitov (5):
  bpf: support 8-byte metafield access
  bpf: introduce BPF_PROG_TYPE_PERF_EVENT program type
  bpf: perf_event progs should only use preallocated maps
  perf, bpf: add perf events core support for BPF_PROG_TYPE_PERF_EVENT
    programs
  samples/bpf: add perf_event+bpf example

Brendan Gregg (1):
  samples/bpf: add sampleip example

 include/linux/bpf.h                 |   4 +
 include/linux/perf_event.h          |   9 ++
 include/uapi/linux/Kbuild           |   1 +
 include/uapi/linux/bpf.h            |   1 +
 include/uapi/linux/bpf_perf_event.h |  18 +++
 kernel/bpf/verifier.c               |  31 +++++-
 kernel/events/core.c                |  89 ++++++++++++++-
 kernel/trace/bpf_trace.c            |  61 +++++++++++
 samples/bpf/Makefile                |   8 ++
 samples/bpf/bpf_helpers.h           |   2 +
 samples/bpf/bpf_load.c              |   7 +-
 samples/bpf/sampleip_kern.c         |  38 +++++++
 samples/bpf/sampleip_user.c         | 196 +++++++++++++++++++++++++++++++++
 samples/bpf/trace_event_kern.c      |  65 +++++++++++
 samples/bpf/trace_event_user.c      | 213 ++++++++++++++++++++++++++++++++++++
 15 files changed, 737 insertions(+), 6 deletions(-)
 create mode 100644 include/uapi/linux/bpf_perf_event.h
 create mode 100644 samples/bpf/sampleip_kern.c
 create mode 100644 samples/bpf/sampleip_user.c
 create mode 100644 samples/bpf/trace_event_kern.c
 create mode 100644 samples/bpf/trace_event_user.c

-- 
2.8.0
