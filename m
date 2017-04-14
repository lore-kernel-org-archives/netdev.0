From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/6] bpf: LRU performance and test-program improvements
Date: Fri, 14 Apr 2017 10:30:24 -0700
Message-ID: <20170414173030.2853860-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43552 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751677AbdDNRac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 13:30:32 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3EHNs3a031399
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29tp4etve6-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:31 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 0e746ae4213811e7b6f80002c99293a0-13f99a0 for <netdev@vger.kernel.org>; Fri,
 14 Apr 2017 10:30:30 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first 4 patches make a few improvements to the LRU tests.

Patch 5/6 is to improve the performance of BPF_F_NO_COMMON_LRU map.

Patch 6/6 adds an example in using LRU map with map-in-map.

Martin KaFai Lau (6):
  bpf: lru: Add test_lru_sanity6 for BPF_F_NO_COMMON_LRU
  bpf: lru: Cleanup test_lru_map.c
  bpf: lru: Refactor LRU map tests in map_perf_test
  bpf: Allow bpf sample programs (*_user.c) to change bpf_map_def
  bpf: lru: Lower the PERCPU_NR_SCANS from 16 to 4
  bpf: lru: Add map-in-map LRU example

 kernel/bpf/bpf_lru_list.c                  |   2 +-
 samples/bpf/bpf_load.c                     | 114 ++++++++++---
 samples/bpf/bpf_load.h                     |  13 ++
 samples/bpf/map_perf_test_kern.c           |  75 +++++++--
 samples/bpf/map_perf_test_user.c           | 247 +++++++++++++++++++++--------
 tools/testing/selftests/bpf/test_lru_map.c | 104 ++++++++----
 6 files changed, 428 insertions(+), 127 deletions(-)

-- 
2.9.3
