From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH v3 net-next 0/4] net: filter: BPF updates
Date: Tue, 19 Mar 2013 17:39:28 +0100
Message-ID: <1363711172-9728-1-git-send-email-dborkman@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40506 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756996Ab3CSQjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:39:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds i) an ancillary operation to the BPF engine and ii) a
BPF JIT image disassembler in order to verify or debug the BPF JIT
compilers under arch/*/net/.

v1 -> v2:
	- No need to reorder choke_skb_cb structure
v2 -> v3:
	- Do not touch nhoff, let it stay as is

Daniel Borkmann (4):
  flow_keys: include thoff into flow_keys for later usage
  net: flow_dissector: add __skb_get_poff to get a start offset to payload
  filter: add ANC_PAY_OFFSET instruction for loading payload start offset
  filter: add minimal BPF JIT emitted image disassembler

 include/linux/filter.h      |   1 +
 include/linux/skbuff.h      |   2 +
 include/net/flow_keys.h     |   1 +
 include/uapi/linux/filter.h |   3 +-
 net/core/filter.c           |   5 +
 net/core/flow_dissector.c   |  59 ++++++++++++
 scripts/bpf_jit_disasm.c    | 216 ++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 286 insertions(+), 1 deletion(-)
 create mode 100644 scripts/bpf_jit_disasm.c

-- 
1.7.11.7
