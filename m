From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next 0/5] bpf: add support for BASE_RTT
Date: Fri, 20 Oct 2017 11:05:38 -0700
Message-ID: <20171020180543.4156833-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Blake Matheny <bmatheny@fb.com>,
        Lawrence Brakmo <brakmo@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58022 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753175AbdJTSF6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 14:05:58 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9KI4WcE005137
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:05:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dqmbgrd2d-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:05:57 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds the following functionality to socket_ops BPF
programs.
1) Add bpf helper function bpf_getsocketops. Currently only supports
   TCP_CONGESTION
2) Add BPF_SOCKET_OPS_BASE_RTT op to get the base RTT of the
   connection. In general, the base RTT indicates the threshold such
   that RTTs above it indicate congestion. More details in the
   relevant patches.   
 
Consists of the following patches:

[PATCH net-next 1/5] bpf: add support for BPF_SOCK_OPS_BASE_RTT
[PATCH net-next 2/5] bpf: Adding helper function bpf_getsockops
[PATCH net-next 3/5] bpf: Add BPF_SOCKET_OPS_BASE_RTT support to
[PATCH net-next 4/5] bpf: sample BPF_SOCKET_OPS_BASE_RTT program
[PATCH net-next 5/5] bpf: create samples/bpf/tcp_bpf.readme

 include/uapi/linux/bpf.h                  | 26 +++++++++++--
 net/core/filter.c                         | 46 ++++++++++++++++++++++-
 net/ipv4/tcp_nv.c                         | 40 +++++++++++++++++++-
 samples/bpf/Makefile                      |  1 +
 samples/bpf/tcp_basertt_kern.c            | 78 +++++++++++++++++++++++++++++++++++++++
 samples/bpf/tcp_bbf.readme                | 27 ++++++++++++++
 tools/testing/selftests/bpf/bpf_helpers.h |  3 ++
7 files changed, 214 insertions(+), 7 deletions(-)
