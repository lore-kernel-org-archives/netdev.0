From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/2] perf, bpf: add support for HW_CACHE and RAW events
Date: Mon, 22 May 2017 15:48:38 -0700
Message-ID: <20170522224840.810121-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59057 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751349AbdEVWsm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 18:48:42 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4MMZHUe014655
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 15:48:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2am439h1t7-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 15:48:42 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 cd258a563f4011e7af430002c95209d8-ca7358f0 for <netdev@vger.kernel.org>;        Mon,
 22 May 2017 15:48:41 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1: add support for HW_CACHE and RAW perf events to bpf:
- similar to PERF_TYPE_RAW and PERF_TYPE_HARDWARE allow PERF_TYPE_HW_CACHE
  events to be accessed via bpf_perf_event_read()
- similar to PERF_TYPE_HARDWARE and PERF_TYPE_SOFTWARE allow bpf programs
  to attch to PERF_TYPE_HW_CACHE and PERF_TYPE_RAW events as
  BPF_PROG_TYPE_PERF_EVENT program type

Patch 2: add tests for HW_CACHE and RAW events

---
Peter,
please review patch 1. It looks trivial and as far as
we can see nothing else needed. The existing perf+bpf infra
covers it just fine.

Thanks!

Teng Qin (2):
  perf, bpf: add support for HW_CACHE and RAW events
  samples/bpf: add samples for HW_CACHE / RAW events

 kernel/bpf/arraymap.c          |   1 +
 kernel/events/core.c           |   4 +-
 kernel/trace/bpf_trace.c       |   1 +
 samples/bpf/bpf_helpers.h      |   2 +-
 samples/bpf/trace_event_user.c |  46 +++++++++++-
 samples/bpf/tracex6_kern.c     |  28 ++++++--
 samples/bpf/tracex6_user.c     | 155 +++++++++++++++++++++++++++++++----------
 7 files changed, 187 insertions(+), 50 deletions(-)

-- 
2.9.3
