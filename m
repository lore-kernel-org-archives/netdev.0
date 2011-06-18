From: greearb@candelatech.com
Subject: [RFC 0/5] Ethernet low-level frame debugging support.
Date: Fri, 17 Jun 2011 17:09:38 -0700
Message-ID: <1308355783-22407-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45551 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758042Ab1FRAJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 20:09:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This builds on the previous patches to allow receiving the
Ethernet FCS.

These patches let one receive errored frames up the stack
and generate frames with customized FCS.  This allows one
to generate and receive frames with bad CRC for testing
and sniffing purposes.

I'll finish send/rcv support for e100,e1000, and e1000e
if these patches are acceptable.

Ben Greear (5):
  net:  Support ethtool ops for rx of errored frames.
  net:  Add pkt-type PACKET_INVALID
  e100:  Support receiving errored frames.
  net:  Support sending frame with specified FCS.
  e1000e:  Support sending frame with custom FCS.

 drivers/net/e100.c           |   42 ++++++++++++++++++++++++++++++++++++++++--
 drivers/net/e1000e/netdev.c  |   11 +++++++++++
 include/asm-generic/socket.h |    7 +++++++
 include/linux/ethtool.h      |    7 +++++++
 include/linux/if_packet.h    |    7 +++++--
 include/linux/skbuff.h       |    5 ++++-
 include/net/sock.h           |    6 ++++++
 net/core/ethtool.c           |    8 ++++++++
 net/core/skbuff.c            |    1 +
 net/core/sock.c              |    7 +++++++
 net/packet/af_packet.c       |   22 ++++++++++++++++++++--
 11 files changed, 116 insertions(+), 7 deletions(-)

-- 
1.7.3.4

