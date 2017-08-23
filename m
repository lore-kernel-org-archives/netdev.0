From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [V2 PATCH net-next 0/5] xdp: more work on xdp tracepoints
Date: Wed, 23 Aug 2017 12:15:14 +0200
Message-ID: <150348327373.23476.14851572406177222309.stgit@firesoul>
References: <599D42B8.6040200@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58996 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753643AbdHWKPU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 06:15:20 -0400
In-Reply-To: <599D42B8.6040200@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More work on streamlining the tracepoints for XDP.

I've created a simple xdp_monitor application that uses this
tracepoint, and prints statistics. Available at github:

https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_monitor_kern.c
https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_monitor_user.c

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
 include/trace/events/xdp.h                    |   36 +++++++++----------
 net/core/dev.c                                |    4 +-
 net/core/filter.c                             |   48 +++++++++++++------------
 5 files changed, 48 insertions(+), 47 deletions(-)
