From: Yonghong Song <yhs@fb.com>
Subject: [PATCH 0/2] bpf: permit bpf program narrower loads for ctx fields
Date: Tue, 13 Jun 2017 15:52:12 -0700
Message-ID: <20170613225214.2854085-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <ast@fb.com>, <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60630 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753217AbdFMWwS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 18:52:18 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DMmr8K000812
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 15:52:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b2nmdgpj1-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 15:52:17 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 f20e221e508a11e794de6fbdf6e974f4-a53328f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 15:52:15 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today, if users try to access a ctx field through a narrower load, e.g.,
__be16 prot = __sk_buff->protocol, verifier will fail.
This set contains the verifier change to permit such loads for
certain ctx fields as well as the new test cases in selftests/bpf.

Yonghong Song (2):
  bpf: permits narrower load from bpf program context fields
  selftests/bpf: Add test cases to test narrower ctx field loads

 include/linux/bpf.h                              |   2 +-
 include/linux/bpf_verifier.h                     |   1 +
 kernel/bpf/verifier.c                            |  71 +++++---
 kernel/trace/bpf_trace.c                         |  21 ++-
 net/core/filter.c                                |  56 +++++--
 tools/testing/selftests/bpf/Makefile             |   3 +-
 tools/testing/selftests/bpf/test_pkt_md_access.c |  35 ++++
 tools/testing/selftests/bpf/test_progs.c         |  21 +++
 tools/testing/selftests/bpf/test_verifier.c      | 200 ++++++++++++++++++-----
 9 files changed, 324 insertions(+), 86 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/test_pkt_md_access.c

-- 
2.9.3
