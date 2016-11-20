From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 0/5] XDP for virtio_net
Date: Sat, 19 Nov 2016 18:49:03 -0800
Message-ID: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bblanco@plumgrid.com,
        john.fastabend@gmail.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch
To: daniel@iogearbox.net, eric.dumazet@gmail.com, mst@redhat.com,
        kubakici@wp.pl, shm@cumulusnetworks.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35649 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753004AbcKTCtc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 21:49:32 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so24713815pga.2
        for <netdev@vger.kernel.org>; Sat, 19 Nov 2016 18:49:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements virtio_net for the mergeable buffers and big_packet
modes. I tested this with vhost_net running on qemu and did not see
any issues.

There are some restrictions for XDP to be enabled (see patch 3) for
more details.

  1. LRO must be off
  2. MTU must be less than PAGE_SIZE
  3. queues must be available to dedicate to XDP
  4. num_bufs received in mergeable buffers must be 1
  5. big_packet mode must have all data on single page

Please review any comments/feedback welcome as always.

v2, fixes rcu usage throughout thanks to Eric and the use of
num_online_cpus() usage thanks to Jakub.

Thanks,
John

---

John Fastabend (4):
      net: virtio dynamically disable/enable LRO
      net: xdp: add invalid buffer warning
      virtio_net: add dedicated XDP transmit queues
      virtio_net: add XDP_TX support

Shrijeet Mukherjee (1):
      virtio_net: Add XDP support


 drivers/net/virtio_net.c |  268 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/filter.h   |    1 
 net/core/filter.c        |    6 +
 3 files changed, 270 insertions(+), 5 deletions(-)
