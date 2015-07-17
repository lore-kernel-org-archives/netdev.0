From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/2] bpf: introduce bpf_skb_vlan_push/pop() helpers
Date: Thu, 16 Jul 2015 19:58:02 -0700
Message-ID: <1437101884-2081-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33016 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbbGQC6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 22:58:10 -0400
Received: by pdbqm3 with SMTP id qm3so54174915pdb.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 19:58:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let eBPF programs call skb_vlan_push/pop via helpers.
JIT changes to accomodate of re-caching of skb->data and headerlen
turned out to be pretty simple.

This patch is on top of Daniel's bpf_get_cgroup_classid():
http://patchwork.ozlabs.org/patch/495826/
to avoid merge conflicts.

Alexei Starovoitov (2):
  bpf: introduce bpf_skb_vlan_push/pop() helpers
  test_bpf: add bpf_skb_vlan_push/pop() tests

 arch/s390/net/bpf_jit_comp.c |    4 ++
 arch/x86/net/bpf_jit_comp.c  |   80 ++++++++++++++++++----------------
 include/linux/bpf.h          |    2 +
 include/linux/filter.h       |    1 +
 include/uapi/linux/bpf.h     |    2 +
 kernel/bpf/core.c            |    1 +
 lib/test_bpf.c               |   98 ++++++++++++++++++++++++++++++++++++++++--
 net/core/filter.c            |   49 +++++++++++++++++++++
 8 files changed, 196 insertions(+), 41 deletions(-)

-- 
1.7.9.5
