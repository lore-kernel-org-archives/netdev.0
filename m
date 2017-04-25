From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 0/4] xdp: use netlink extended ACK reporting
Date: Tue, 25 Apr 2017 01:06:40 -0700
Message-ID: <20170425080644.122536-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35403 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1172282AbdDYIIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 04:08:13 -0400
Received: by mail-pg0-f43.google.com with SMTP id 72so24747663pge.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 01:08:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series is an attempt to make XDP more user friendly by 
enabling exploiting the recently added netlink extended ACK 
reporting to carry messages to user space.

I made iproute2 parse the extended messages and have it showing 
the errors like this:

# ip link set dev p4p1 xdp obj ipip_prepend.o sec ".text"
RTNETLINK answers: Invalid argument (MTU too large w/ XDP enabled)

Where the message is coming directly from the driver.  There could
still be a bit of a leap for a complete novice from the message 
above to the right settings.  I wonder if it would be worthwhile
adding #defines for the most common configuration conflicts?
Sharing the messages verbatim between drivers could make them easier
to google.

Also - is anyone working on adding proper extack support to iproute2?
The code I have right now is a bit of a hack...

Jakub Kicinski (4):
  netlink: make extended ACK setting NULL-friendly
  xdp: propagate extended ack to XDP setup
  nfp: make use of extended ack message reporting
  virtio_net: make use of extended ack message reporting

 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  3 ++-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 22 +++++++++++++---------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  4 ++--
 drivers/net/virtio_net.c                           | 11 +++++++----
 include/linux/netdevice.h                          | 10 ++++++++--
 include/linux/netlink.h                            | 12 ++++++++----
 net/core/dev.c                                     |  5 ++++-
 net/core/rtnetlink.c                               | 13 ++++++++-----
 8 files changed, 52 insertions(+), 28 deletions(-)

-- 
2.11.0
