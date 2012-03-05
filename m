From: Richard Weinberger <richard@nod.at>
Subject: [PATCH v6] Netfilter ring buffer support
Date: Tue,  6 Mar 2012 00:19:42 +0100
Message-ID: <1330989588-26833-1-git-send-email-richard@nod.at>
Cc: jengelh@medozas.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rostedt@goodmis.org
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set merges ipt_LOG and ip6t_LOG and adds ring buffer support
to xt_LOG.

Using "--ring" an user can create LOG rules which log messages into
one or more ring buffers.
Each ring buffer is represented as pipe-like file in
/proc/net/netfilter/nf_log_ring/.

Ring buffer support can be enabled/disabled using
CONFIG_NETFILTER_XT_TARGET_LOG_RING.

Changes since v1:
 - Merged ipt_LOG and ip6t_LOG
 - Implemented ring buffer support as part of xt_LOG.

Changes since v2:
 - Fixed struct xt_log_info_v1's data layout
 - Removed the sizeof(void *) hack
 - Replaced BUG() by WARN_ON_ONCE()

Changes since v3:
 - Merged xt_LOG_core.c and xt_LOG_ring.c into xt_LOG.c
 - Made checkpatch.pl happy

Changes since v4:
 - Fixed a typo in include/linux/netfilter/Kbuild
   (Thanks Bastian!)

Changes since v5:
 - Made timestamp support a separate patch
 - Renamed xt_LOG_ring to nf_log_ring
 - Removed unused prototypes from xt_log.h
 - Renamed find_next_entry_inc() to find_next_iter_entry()
 - Fixed OOM error path in rlog_open_pipe()

Patch 1 and 2 have already been applied to net-next.git.

[PATCH 1/6] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
[PATCH 2/6] netfilter: xt_LOG: fix bogus extra layer-4 logging
[PATCH 3/6] ring_buffer: Export for_each_buffer_cpu()
[PATCH 4/6] xt_log: Make printk() in sb_close() optional
[PATCH 5/6] Netfilter: xt_LOG: Implement ring buffer support
[PATCH 6/6] Netfilter: xt_LOG: Add timestamp support

Thanks,
//richard
