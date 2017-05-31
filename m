From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/8] Introduce bpf ID
Date: Tue, 30 May 2017 17:08:29 -0700
Message-ID: <cover.1496189155.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46031 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750922AbdEaAIk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:08:40 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4V04v78024688
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:08:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2asgt2gd6f-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:08:39 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 4bb9402e459511e7b7cb6900506838e1-7df338f0 for <netdev@vger.kernel.org>;        Tue,
 30 May 2017 17:08:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series:
1) Introduce ID for both bpf_prog and bpf_map.
2) Add bpf commands to iterate the prog IDs and map
   IDs of the system.
3) Add bpf commands to get a prog/map fd from an ID
4) Add bpf command to get prog/map info from a fd.
   The prog/map info is a jump start in this patchset
   and it is not meant to be a complete list.  They can
   be extended in the future patches.

Martin KaFai Lau (8):
  bpf: Introduce bpf_prog ID
  bpf: Introduce bpf_map ID
  bpf: Add BPF_(PROG|MAP)_GET_NEXT_ID command
  bpf: Add BPF_PROG_GET_FD_BY_ID
  bpf: Add BPF_MAP_GET_FD_BY_ID
  bpf: Add jited_len to struct bpf_prog
  bpf: Add BPF_OBJ_GET_INFO_BY_FD
  bpf: Test for bpf ID

 arch/arm64/net/bpf_jit_comp.c             |   1 +
 arch/powerpc/net/bpf_jit_comp64.c         |   1 +
 arch/s390/net/bpf_jit_comp.c              |   1 +
 arch/sparc/net/bpf_jit_comp_64.c          |   1 +
 arch/x86/net/bpf_jit_comp.c               |   1 +
 include/linux/bpf.h                       |   2 +
 include/linux/filter.h                    |   3 +-
 include/uapi/linux/bpf.h                  |  41 +++
 kernel/bpf/syscall.c                      | 433 ++++++++++++++++++++++++++++--
 tools/include/uapi/linux/bpf.h            |  41 +++
 tools/lib/bpf/bpf.c                       |  68 +++++
 tools/lib/bpf/bpf.h                       |   5 +
 tools/testing/selftests/bpf/Makefile      |   2 +-
 tools/testing/selftests/bpf/test_obj_id.c |  35 +++
 tools/testing/selftests/bpf/test_progs.c  | 191 +++++++++++++
 15 files changed, 798 insertions(+), 28 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/test_obj_id.c

-- 
2.9.3
