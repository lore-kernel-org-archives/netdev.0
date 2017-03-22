From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/4] bpf: Add map-in-map support
Date: Wed, 22 Mar 2017 10:00:31 -0700
Message-ID: <20170322170035.923581-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        FB Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46803 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760963AbdCVRAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 13:00:53 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2MGxW4k001682
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 10:00:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29bp0vjgpn-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 10:00:36 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 1118e3520f2111e7a7b30002c9931860-fe9fa9a0 for <netdev@vger.kernel.org>;        Wed,
 22 Mar 2017 10:00:35 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds map-in-map support (map->map).
One use case is the (vips -> webservers) in the L4 load balancer so
that different vips can be backed by different set of webservers.

Please refer to the individual commit log for details.

Martin KaFai Lau (4):
  bpf: Fix and simplifications on inline map lookup
  bpf: Add array of maps support
  bpf: Add hash of maps support
  bpf: Add tests for map-in-map

 include/linux/bpf.h                         |   3 +
 include/uapi/linux/bpf.h                    |   3 +
 kernel/bpf/Makefile                         |   2 +-
 kernel/bpf/arraymap.c                       |  74 ++++++++++--
 kernel/bpf/hashtab.c                        | 121 +++++++++++++++++++
 kernel/bpf/map_in_map.c                     |  97 ++++++++++++++++
 kernel/bpf/map_in_map.h                     |  23 ++++
 kernel/bpf/syscall.c                        |  13 ++-
 kernel/bpf/verifier.c                       |  57 +++++++--
 samples/bpf/Makefile                        |   4 +
 samples/bpf/bpf_helpers.h                   |   1 +
 samples/bpf/bpf_load.c                      |  22 +++-
 samples/bpf/test_map_in_map_kern.c          | 173 ++++++++++++++++++++++++++++
 samples/bpf/test_map_in_map_user.c          | 116 +++++++++++++++++++
 tools/include/uapi/linux/bpf.h              |   3 +
 tools/lib/bpf/bpf.c                         |  17 +++
 tools/lib/bpf/bpf.h                         |   2 +
 tools/testing/selftests/bpf/test_verifier.c | 131 ++++++++++++++++++---
 18 files changed, 823 insertions(+), 39 deletions(-)
 create mode 100644 kernel/bpf/map_in_map.c
 create mode 100644 kernel/bpf/map_in_map.h
 create mode 100644 samples/bpf/test_map_in_map_kern.c
 create mode 100644 samples/bpf/test_map_in_map_user.c

-- 
2.9.3
