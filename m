From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH RFC 0/2] ila: ilarouter bpf code for tc and xdp
Date: Fri, 23 Sep 2016 10:16:33 -0700
Message-ID: <1474650995-2031928-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Tom Herbert <tom@herbertland.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36684 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1760508AbcIWRQi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 13:16:38 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u8NHDun6027965
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 10:16:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 25mqbd0h4e-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 10:16:37 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 7b17724481b111e6ab460002c9931860-ebaf7a50 for <netdev@vger.kernel.org>;        Fri,
 23 Sep 2016 10:16:35 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Yue <haoxuany@andrew.cmu.edu>

Jesper,

here is old email and cover letter that didn't make it to the list
due to vger outage (I guess).
The verifier patch that Aaron is talking about has landed long ago.

The dataplane of ILA router is very short and simple.
Control plane is very different matter. It's not ready for prime time yet.

----------

This patch contains the tc and xdp implementation of kernelspace bpf code.
It requires userspace to insert to the ILA bpf maps, in tc's case, the 
precomputed ILA mappings, and in xdp's case, both the precomputed ILA
mappings and the MAC address.

The xdp bpf code also requires a verifier patch to allow direct map access
from the packet (will be patched in by Alexei).

Aaron Yue (2):
  samples/bpf: ilarouter for tc
  samples/bpf: ilarouter for xdp

 samples/bpf/Makefile        |   2 +
 samples/bpf/ila.h           |  80 ++++++++++++++++++++++++++++
 samples/bpf/ilarouter_tc.c  | 124 ++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/ilarouter_xdp.c |  88 +++++++++++++++++++++++++++++++
 samples/bpf/inet_helper.h   |  38 ++++++++++++++
 5 files changed, 332 insertions(+)
 create mode 100644 samples/bpf/ila.h
 create mode 100644 samples/bpf/ilarouter_tc.c
 create mode 100644 samples/bpf/ilarouter_xdp.c
 create mode 100644 samples/bpf/inet_helper.h

-- 
2.8.0.rc2
