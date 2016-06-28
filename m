From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/6] BPF helper improvements
Date: Tue, 28 Jun 2016 12:18:22 +0200
Message-ID: <cover.1467106474.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54506 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbcF1KuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 06:50:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds various BPF helper improvements, that is, cleaning
up and adding BPF_F_CURRENT_CPU flag for tracing helper, allowing
for preemption checks on bpf_get_smp_processor_id() helper, and
adding two new helpers bpf_skb_change_{proto, type} for tc related
programs. For further details please see individual patches.

Note, this set requires -net to be merged into -net-next tree first.

Thanks a lot!

Daniel Borkmann (6):
  bpf: minor cleanups on fd maps and helpers
  bpf, trace: fetch current cpu only once
  bpf, trace: add BPF_F_CURRENT_CPU flag for bpf_perf_event_read
  bpf: don't use raw processor id in generic helper
  bpf: add bpf_skb_change_proto helper
  bpf: add bpf_skb_change_type helper

 include/uapi/linux/bpf.h |  25 ++++-
 kernel/bpf/core.c        |   3 +-
 kernel/bpf/helpers.c     |   2 +-
 kernel/trace/bpf_trace.c |  32 +++----
 net/core/filter.c        | 234 ++++++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 275 insertions(+), 21 deletions(-)

-- 
1.9.3
