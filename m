From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next 1/2] bpf: Allow CGROUP_SKB eBPF program to access sk_buff
Date: Wed, 31 May 2017 11:06:52 -0700
Message-ID: <1496254013-18719-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33521 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdEaSHF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:07:05 -0400
Received: by mail-pg0-f66.google.com with SMTP id s62so2729485pgc.0
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 11:07:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

This allows cgroup eBPF program to classify packet based on their
protocol or other detail information. Currently program need
CAP_NET_ADMIN privilege to attach a cgroup eBPF program, and A
process with CAP_NET_ADMIN can already see all packets on the system,
for example, by creating an iptables rules that causes the packet to
be passed to userspace via NFLOG.

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 kernel/bpf/verifier.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 339c8a1..94a9bc9 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2419,6 +2419,7 @@ static bool may_access_skb(enum bpf_prog_type type)
 	case BPF_PROG_TYPE_SOCKET_FILTER:
 	case BPF_PROG_TYPE_SCHED_CLS:
 	case BPF_PROG_TYPE_SCHED_ACT:
+	case BPF_PROG_TYPE_CGROUP_SKB:
 		return true;
 	default:
 		return false;
-- 
2.7.4
