From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 0/2] bpf: performance improvements
Date: Tue, 15 Sep 2015 23:05:41 -0700
Message-ID: <1442383543-4720-1-git-send-email-ast@plumgrid.com>
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34226 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbbIPGFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 02:05:54 -0400
Received: by padhy16 with SMTP id hy16so199231994pad.1
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 23:05:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2: dropped redundant iff_up check in patch 2

At plumbers we discussed different options on how to get rid of skb_clone
from bpf_clone_redirect(), the patch 2 implements the best option.
Patch 1 adds 'integrated exts' to cls_bpf to improve performance by
combining simple actions into bpf classifier.

Alexei Starovoitov (1):
  bpf: add bpf_redirect() helper

Daniel Borkmann (1):
  cls_bpf: introduce integrated actions

 include/net/sch_generic.h    |    3 ++-
 include/uapi/linux/bpf.h     |    9 +++++++
 include/uapi/linux/pkt_cls.h |    4 +++
 net/core/dev.c               |    8 ++++++
 net/core/filter.c            |   58 +++++++++++++++++++++++++++++++++++++++
 net/sched/act_bpf.c          |    1 +
 net/sched/cls_bpf.c          |   61 ++++++++++++++++++++++++++++++++++--------
 samples/bpf/bpf_helpers.h    |    4 +++
 samples/bpf/tcbpf1_kern.c    |   24 ++++++++++++++++-
 9 files changed, 159 insertions(+), 13 deletions(-)

-- 
1.7.9.5
