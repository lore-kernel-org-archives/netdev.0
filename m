From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH 0/5] XDP for virtio_net
Date: Fri, 18 Nov 2016 10:59:09 -0800
Message-ID: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.fastabend@gmail.com, brouer@redhat.com
To: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33123 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbcKRS72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 13:59:28 -0500
Received: by mail-pf0-f196.google.com with SMTP id 144so14039330pfv.0
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 10:59:28 -0800 (PST)
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


 drivers/net/virtio_net.c |  264 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/filter.h   |    1 
 net/core/filter.c        |    6 +
 3 files changed, 267 insertions(+), 4 deletions(-)
