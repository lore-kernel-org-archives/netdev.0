From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/6] BPF updates
Date: Fri, 19 Feb 2016 23:05:21 +0100
Message-ID: <cover.1455899111.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35324 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbcBSWFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 17:05:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set contains various updates for eBPF, i.e. the addition of a
generic csum helper function and other misc bits that mostly improve
existing helpers and ease programming with eBPF on cls_bpf. For more
details, please see individual patches.

Set is rebased on top of http://patchwork.ozlabs.org/patch/584465/.

Thanks!

Daniel Borkmann (6):
  bpf: add new arg_type that allows for 0 sized stack buffer
  bpf: add generic bpf_csum_diff helper
  bpf: remove artificial bpf_skb_{load,store}_bytes buffer limitation
  bpf: try harder on clones when writing into skb
  bpf: fix csum update in bpf_l4_csum_replace helper for udp
  bpf: don't emit mov A,A on return

 include/linux/bpf.h      |   1 +
 include/linux/skbuff.h   |   7 ++++
 include/uapi/linux/bpf.h |  12 ++++++
 kernel/bpf/verifier.c    |  42 ++++++++++++++-----
 net/core/filter.c        | 103 ++++++++++++++++++++++++++++++++++++++---------
 net/sched/act_csum.c     |   8 +---
 net/sched/act_nat.c      |  18 +++------
 7 files changed, 142 insertions(+), 49 deletions(-)

-- 
1.9.3
