From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC 0/3] tun zerocopy stats
Date: Fri,  6 Oct 2017 18:25:13 -0400
Message-ID: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:47325 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdJFWZT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 18:25:19 -0400
Received: by mail-qt0-f193.google.com with SMTP id z50so29077967qtj.4
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 15:25:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add zerocopy transfer statistics to the vhost_net/tun zerocopy path.

I've been using this to verify recent changes to zerocopy tuning [1].
Sharing more widely, as it may be useful in similar future work.

Use ethtool stats as interface, as these are defined per device
driver and can easily be extended.

Make the zerocopy release callback take an extra hop through the tun
driver to allow the driver to increment its counters.

Care must be taken to avoid adding an alloc/free to this hot path.
Since the caller already must allocate a ubuf_info, make it allocate
two at a time and grant one to the tun device.

 1/3: introduce ethtool stats (`ethtool -S $DEV`) for tun devices
 2/3: add zerocopy tx and tx_err counters
 3/3: convert vhost_net to pass a pair of ubuf_info to tun

[1] http://patchwork.ozlabs.org/patch/822613/

Willem de Bruijn (3):
  tun: ethtool stats
  tun: expand ethtool stats with zerocopy
  vhost_net: support tun zerocopy stats

 drivers/net/tun.c   | 111 ++++++++++++++++++++++++++++++++++++++++++++++++----
 drivers/vhost/net.c |   7 ++--
 2 files changed, 108 insertions(+), 10 deletions(-)

-- 
2.14.2.920.gcf0c67979c-goog
