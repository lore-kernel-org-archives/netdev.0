From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 0/6] bpf: LRU map
Date: Fri, 11 Nov 2016 10:55:05 -0800
Message-ID: <1478890511-1346984-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35468 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934156AbcKKSzX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 13:55:23 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uABIsWpV028748
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 10:55:22 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 26njue0m7y-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 10:55:22 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 65769a2ca84011e6985324be05956610-81dfda50 for <netdev@vger.kernel.org>;        Fri,
 11 Nov 2016 10:55:21 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch set adds LRU map implementation to the existing BPF map
family.

The first few patches introduce the basic BPF LRU list
implementation.

The later patches introduce the LRU versions of the
existing BPF_MAP_TYPE_LRU_[PERCPU_]HASH maps by leveraging
the BPF LRU list.

v2:
- Added a percpu LRU list option which can be specified as
  a map attribute.

  [Note: percpu LRU list has nothing to do with the map's value]

- Removed the cpu variable from the struct bpf_lru_locallist
  since it is not needed.

- Changed the __bpf_lru_node_move_out to __bpf_lru_node_move_to_free in
  patch 1 to prepare the percpu LRU list in patch 2.

- Moved the test_lru_map under selftests

- Refactored a few things in the test codes

Thanks,
-- Martin
