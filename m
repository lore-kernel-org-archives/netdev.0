From: Jason Wang <jasowang@redhat.com>
Subject: [net-next 0/5] set transport header for untrusted packets
Date: Tue, 26 Mar 2013 14:19:54 +0800
Message-ID: <1364278799-37285-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753759Ab3CZG3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 02:29:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't set transport header for untrusted packets in the past, but for the
follwoing reasons, we need to do it now.

- Better packet length estimation (introduced in 1def9238) needs l4 header for
  gso packets to compute the header length.
- Some driver needs l4 header (e.g. ixgbe needs tcp header to do atr).

So this patches tries to set transport header for packets from untrusted source
(netback, packet, tuntap, macvtap). Plus a fix for better estimation on packet
length for DODGY packet.

Tested on tun/macvtap/packet, compile test on netback.

Jason Wang (5):
  macvtap: set transport header before passing skb to lower device
  tuntap: set transport header before passing it to kernel
  packet: set transport header before doing xmit
  netback: set transport header before passing it to kernel
  net_sched: better precise estimation on packet length for untrusted
    packets

 drivers/net/macvtap.c             |    9 +++++++++
 drivers/net/tun.c                 |   10 ++++++++++
 drivers/net/xen-netback/netback.c |   12 ++++++++++++
 net/core/dev.c                    |    8 +++++++-
 net/packet/af_packet.c            |   21 +++++++++++++++++++++
 5 files changed, 59 insertions(+), 1 deletions(-)
