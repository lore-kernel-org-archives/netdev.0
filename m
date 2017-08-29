From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next 0/7] XDP redirect tracepoints
Date: Tue, 29 Aug 2017 16:37:35 +0200
Message-ID: <150401743083.16384.15778781741742858567.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48664 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752746AbdH2Ohj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 10:37:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I feel this is as far as I can take the tracepoint infrastructure to
assist XDP monitoring.

Tracepoints comes with a base overhead of 25 nanosec for an attached
bpf_prog, and 48 nanosec for using a full perf record. This is
problematic for the XDP use-case, but it is very convenient to use the
existing perf infrastructure.

>From a performance perspective, the real solution would be to attach
another bpf_prog (that understand xdp_buff), but I'm not sure we want
to introduce yet another bpf attach API for this.

One thing left is to standardize the possible err return codes, to a
limited set, to allow easier (and faster) mapping into a bpf map.

---

Jesper Dangaard Brouer (7):
      xdp: remove redundant argument to trace_xdp_redirect
      xdp: tracepoint xdp_redirect also need a map argument
      xdp: make xdp tracepoints report bpf prog id instead of prog_tag
      xdp: separate xdp_redirect tracepoint in error case
      xdp: separate xdp_redirect tracepoint in map case
      samples/bpf: xdp_redirect load XDP dummy prog on TX device
      samples/bpf: xdp_monitor tool based on tracepoints


 include/trace/events/xdp.h          |  100 ++++++++++--
 net/core/filter.c                   |   37 +++-
 samples/bpf/Makefile                |    4 
 samples/bpf/xdp_monitor_kern.c      |   88 ++++++++++
 samples/bpf/xdp_monitor_user.c      |  295 +++++++++++++++++++++++++++++++++++
 samples/bpf/xdp_redirect_kern.c     |   11 +
 samples/bpf/xdp_redirect_map_kern.c |   11 +
 samples/bpf/xdp_redirect_map_user.c |   22 ++-
 samples/bpf/xdp_redirect_user.c     |   21 ++
 9 files changed, 543 insertions(+), 46 deletions(-)
 create mode 100644 samples/bpf/xdp_monitor_kern.c
 create mode 100644 samples/bpf/xdp_monitor_user.c
