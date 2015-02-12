From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next v2 0/3] net: Introducing socket mark receive socket option
Date: Thu, 12 Feb 2015 06:32:12 +0200
Message-ID: <1423715535-884-1-git-send-email-eyal.birger@gmail.com>
Cc: netdev@vger.kernel.org, edumazet@google.com,
	shmulik.ladkani@gmail.com, Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:50460 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbbBLEc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 23:32:29 -0500
Received: by mail-we0-f180.google.com with SMTP id k11so7574510wes.11
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 20:32:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set introduces a new socket option for fetching the mark
of skbs passed to sockets as ancillary data.

A userspace program may wish to receive the mark of packets it
receives, for example for distinguishing between different TPROXY
diversion rules to the same userspace proxy socket.

The patch set includes a minor function renaming, as well as a
change in struct sk_buff for allowing skb->mark to persist after
being queued to the socket queue.

---
Changes in v2:
- Function parameter indentation
- Commit message formatting
---

Eyal Birger (3):
  net: Rename sock_recv_ts_and_drops() to sock_cmsg_recv()
  net: use skb->priority for overloading skb->dropcount and
    skb->reserved_tailroom instead of skb->mark
  net: Introducing socket mark receive socket option

 arch/alpha/include/uapi/asm/socket.h   |  2 ++
 arch/avr32/include/uapi/asm/socket.h   |  2 ++
 arch/cris/include/uapi/asm/socket.h    |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  2 ++
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  2 ++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/powerpc/include/uapi/asm/socket.h |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/linux/skbuff.h                 |  4 ++--
 include/net/sock.h                     | 18 ++++++++++--------
 include/uapi/asm-generic/socket.h      |  2 ++
 net/atm/common.c                       |  2 +-
 net/bluetooth/af_bluetooth.c           |  4 ++--
 net/can/bcm.c                          |  2 +-
 net/can/raw.c                          |  2 +-
 net/core/sock.c                        |  8 ++++++++
 net/ieee802154/socket.c                |  4 ++--
 net/ipv4/raw.c                         |  2 +-
 net/ipv4/udp.c                         |  2 +-
 net/ipv6/raw.c                         |  2 +-
 net/ipv6/udp.c                         |  2 +-
 net/key/af_key.c                       |  2 +-
 net/packet/af_packet.c                 |  2 +-
 net/rxrpc/ar-recvmsg.c                 |  2 +-
 net/sctp/socket.c                      |  2 +-
 net/socket.c                           | 15 ++++++++++++---
 31 files changed, 75 insertions(+), 28 deletions(-)

-- 
2.1.4
