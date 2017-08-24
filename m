From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [V3 PATCH net-next 0/5] xdp: more work on xdp tracepoints
Date: Thu, 24 Aug 2017 12:32:58 +0200
Message-ID: <150357074701.26663.4047992776649697788.stgit@firesoul>
References: <20170823.170737.931093928208799430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38486 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751276AbdHXKdC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 06:33:02 -0400
In-Reply-To: <20170823.170737.931093928208799430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More work on streamlining and performance optimizing the tracepoints
for XDP.

I've created a simple xdp_monitor application that uses this
tracepoint, and prints statistics. Available at github:

https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_monitor_kern.c
https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_monitor_user.c

The improvement over tracepoint with strcpy: 9810372 - 8428762 = +1381610 pps faster
 - (1/9810372 - 1/8428762)*10^9 = -16.7 nanosec
 - 100-(8428762/9810372*100) = strcpy-trace is 14.08% slower
 - 981037/8428762*100 = removing strcpy made it 11.64% faster

V3: Fix merge conflict with commit e4a8e817d3cb ("bpf: misc xdp redirect cleanups")
V2: Change trace_xdp_redirect() to align with args of trace_xdp_exception()

---

Jesper Dangaard Brouer (5):
      xdp: remove bpf_warn_invalid_xdp_redirect
      xdp: make generic xdp redirect use tracepoint trace_xdp_redirect
      ixgbe: use return codes from ndo_xdp_xmit that are distinguishable
      xdp: remove net_device names from xdp_redirect tracepoint
      xdp: get tracepoints xdp_exception and xdp_redirect in sync


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 +-
 include/linux/filter.h                        |    3 +-
 include/trace/events/xdp.h                    |   36 ++++++++++---------
 net/core/dev.c                                |    4 +-
 net/core/filter.c                             |   47 +++++++++++++------------
 5 files changed, 49 insertions(+), 45 deletions(-)
