From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/4] xdp: use netlink extended ACK reporting
Date: Sun, 30 Apr 2017 21:46:44 -0700
Message-ID: <20170501044648.13022-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com, brouer@redhat.com, jhs@mojatatu.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34599 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969165AbdEAErO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 00:47:14 -0400
Received: by mail-pg0-f51.google.com with SMTP id v1so41039472pgv.1
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 21:47:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series is an attempt to make XDP more user friendly by 
enabling exploiting the recently added netlink extended ACK 
reporting to carry messages to user space.

David Ahern's iproute2 ext ack patches for ip link are sufficient
to show the errors like this:

# ip link set dev p4p1 xdp obj ipip_prepend.o sec ".text"
Error: nfp: MTU too large w/ XDP enabled

Where the message is coming directly from the driver.  There could
still be a bit of a leap for a complete novice from the message 
above to the right settings, but it's a big improvement over the
standard "Invalid argument" message.

v1/non-rfc:
 - add a separate macro in patch 1;
 - add KBUILD_MODNAME as part of the message (Daniel);
 - don't print the error to logs in patch 1.

Jakub Kicinski (4):
  netlink: add NULL-friendly helper for setting extended ACK message
  xdp: propagate extended ack to XDP setup
  nfp: make use of extended ack message reporting
  virtio_net: make use of extended ack message reporting

 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  3 ++-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 22 +++++++++++++---------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  4 ++--
 drivers/net/virtio_net.c                           | 11 +++++++----
 include/linux/netdevice.h                          | 10 ++++++++--
 include/linux/netlink.h                            |  8 ++++++++
 net/core/dev.c                                     |  5 ++++-
 net/core/rtnetlink.c                               | 13 ++++++++-----
 8 files changed, 52 insertions(+), 24 deletions(-)

-- 
2.11.0
