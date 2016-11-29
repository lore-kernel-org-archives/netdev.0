From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 0/6] XDP for virtio_net
Date: Tue, 29 Nov 2016 12:05:20 -0800
Message-ID: <20161129200450.26752.86882.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.fastabend@gmail.com, brouer@redhat.com
To: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33281 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755845AbcK2UFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:05:39 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so17306707pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 12:05:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements virtio_net for the mergeable buffers and big_packet
modes. I tested this with vhost_net running on qemu and did not see
any issues. For testing num_buf > 1 I added a hack to vhost driver
to only but 100 bytes per buffer.

There are some restrictions for XDP to be enabled and work well
(see patch 3) for more details.

  1. LRO must be off
  2. MTU must be less than PAGE_SIZE
  3. queues must be available to dedicate to XDP
  4. num_bufs received in mergeable buffers must be 1
  5. big_packet mode must have all data on single page

Please review any comments/feedback welcome as always.

v2, fixes rcu usage throughout thanks to Eric and the use of
num_online_cpus() usage thanks to Jakub.

v3, add slowpath patch to handle num_bufs > 1

Thanks,
John
---

John Fastabend (6):
      net: virtio dynamically disable/enable LRO
      net: xdp: add invalid buffer warning
      virtio_net: Add XDP support
      virtio_net: add dedicated XDP transmit queues
      virtio_net: add XDP_TX support
      virtio_net: xdp, add slowpath case for non contiguous buffers


 drivers/net/virtio_net.c |  344 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/filter.h   |    1 
 net/core/filter.c        |    6 +
 3 files changed, 346 insertions(+), 5 deletions(-)
