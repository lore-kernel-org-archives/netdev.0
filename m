From: greearb@candelatech.com
Subject: [PATCH v2 0/5]  Ethernet low-level frame debugging support.
Date: Sat, 18 Jun 2011 13:47:20 -0700
Message-ID: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33313 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab1FRUrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 16:47:32 -0400
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

v2:  Change 'kludge' to fcs_len in af_packet.c
     Add SO_NOFCS to the rest of the various arch socket.h files.

*** BLURB HERE ***

Ben Greear (5):
  net:  Support ethtool ops for rx of errored frames.
  net:  Add pkt-type PACKET_INVALID
  e100:  Support receiving errored frames.
  net:  Support sending frame with specified FCS.
  e1000e:  Support sending frame with custom FCS.

 arch/alpha/include/asm/socket.h   |    1 +
 arch/arm/include/asm/socket.h     |    1 +
 arch/avr32/include/asm/socket.h   |    1 +
 arch/cris/include/asm/socket.h    |    1 +
 arch/frv/include/asm/socket.h     |    1 +
 arch/h8300/include/asm/socket.h   |    1 +
 arch/ia64/include/asm/socket.h    |    1 +
 arch/m32r/include/asm/socket.h    |    1 +
 arch/m68k/include/asm/socket.h    |    1 +
 arch/mips/include/asm/socket.h    |    1 +
 arch/mn10300/include/asm/socket.h |    1 +
 arch/parisc/include/asm/socket.h  |    1 +
 arch/powerpc/include/asm/socket.h |    1 +
 arch/s390/include/asm/socket.h    |    1 +
 arch/sparc/include/asm/socket.h   |    1 +
 arch/xtensa/include/asm/socket.h  |    1 +
 drivers/net/e100.c                |   42 +++++++++++++++++++++++++++++++++++-
 drivers/net/e1000e/netdev.c       |   11 +++++++++
 include/asm-generic/socket.h      |    7 ++++++
 include/linux/ethtool.h           |    7 ++++++
 include/linux/if_packet.h         |    7 ++++-
 include/linux/skbuff.h            |    5 +++-
 include/net/sock.h                |    6 +++++
 net/core/ethtool.c                |    8 +++++++
 net/core/skbuff.c                 |    1 +
 net/core/sock.c                   |    7 ++++++
 net/packet/af_packet.c            |   18 ++++++++++++++-
 27 files changed, 128 insertions(+), 7 deletions(-)

-- 
1.7.3.4

