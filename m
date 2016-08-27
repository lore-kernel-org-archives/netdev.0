From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/6] perf, bpf: add support for bpf in sw/hw perf_events
Date: Fri, 26 Aug 2016 19:31:18 -0700
Message-ID: <1472265084-1767670-1-git-send-email-ast@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:61814 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754510AbcH0Cbk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 22:31:40 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u7R2TDYN010995
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 19:31:25 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2530q90cw9-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 19:31:25 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 591b7b366bfe11e685870002c9931860-3a3f5aa0 for <netdev@vger.kernel.org>;        Fri,
 26 Aug 2016 19:31:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter, Dave,

this patch set is a follow up to the discussion:
https://lkml.org/lkml/2016/8/4/304
It turned out to be simpler than what we discussed.

Patches 1-3 is a bpf-side prep for the main patch 4
that adds bpf program as an overflow_handler to sw and hw perf_events.
Peter, please review.

Patches 5 and 6 are tests/examples from myself and Brendan.

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
 include/linux/perf_event.h          |   7 ++
 include/uapi/linux/Kbuild           |   1 +
 include/uapi/linux/bpf.h            |   1 +
 include/uapi/linux/bpf_perf_event.h |  18 +++
 kernel/bpf/verifier.c               |  31 +++++-
 kernel/events/core.c                |  82 +++++++++++++-
 kernel/trace/bpf_trace.c            |  57 ++++++++++
 samples/bpf/Makefile                |   8 ++
 samples/bpf/bpf_helpers.h           |   2 +
 samples/bpf/bpf_load.c              |   7 +-
 samples/bpf/sampleip_kern.c         |  38 +++++++
 samples/bpf/sampleip_user.c         | 196 +++++++++++++++++++++++++++++++++
 samples/bpf/trace_event_kern.c      |  65 +++++++++++
 samples/bpf/trace_event_user.c      | 213 ++++++++++++++++++++++++++++++++++++
 15 files changed, 724 insertions(+), 6 deletions(-)
 create mode 100644 include/uapi/linux/bpf_perf_event.h
 create mode 100644 samples/bpf/sampleip_kern.c
 create mode 100644 samples/bpf/sampleip_user.c
 create mode 100644 samples/bpf/trace_event_kern.c
 create mode 100644 samples/bpf/trace_event_user.c

-- 
2.8.0
