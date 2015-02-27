From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 0/2] net: Remove iocb argument from sendmsg and recvmsg
Date: Fri, 27 Feb 2015 19:06:35 +0800
Message-ID: <1425035198-12547-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <erik.hugne@ericsson.com>,
	<jon.maloy@ericsson.com>
To: <viro@ZenIV.linux.org.uk>, <hch@lst.de>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:33450 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbbB0LGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 06:06:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is only one user - TIPC whose sendmsg() instances
using iocb argument. Meanwhile, there is no user using iocb argument
in its recvmsg() instance. Therefore, if we eliminate the werid usage
of iobc argument from TIPC, the iocb argument can be removed from
all sendmsg() and recvmsg() instances of the whole network stack.

By the way, as patch #2 is very big, I can divide it into smaller
patches regarding module in next version if necessary.

Reference:
https://patchwork.ozlabs.org/patch/433960/

Ying Xue (2):
  tipc: Don't use iocb argument in socket layer
  net: Remove iocb argument from sendmsg and recvmsg

 crypto/algif_hash.c               |    8 +--
 crypto/algif_rng.c                |    4 +-
 crypto/algif_skcipher.c           |    8 +--
 drivers/isdn/mISDN/socket.c       |    7 ++-
 drivers/net/macvtap.c             |    9 ++--
 drivers/net/ppp/pppoe.c           |    8 +--
 drivers/net/tun.c                 |    6 +--
 drivers/vhost/net.c               |    6 +--
 include/linux/net.h               |   10 ++--
 include/net/af_vsock.h            |    4 +-
 include/net/bluetooth/bluetooth.h |    8 +--
 include/net/inet_common.h         |    7 ++-
 include/net/ping.h                |    7 ++-
 include/net/sock.h                |   16 +++---
 include/net/tcp.h                 |    7 ++-
 include/net/udp.h                 |    3 +-
 net/appletalk/ddp.c               |    7 ++-
 net/atm/common.c                  |    7 ++-
 net/atm/common.h                  |    7 ++-
 net/ax25/af_ax25.c                |    7 ++-
 net/bluetooth/af_bluetooth.c      |    8 +--
 net/bluetooth/hci_sock.c          |    8 +--
 net/bluetooth/l2cap_sock.c        |   12 ++---
 net/bluetooth/rfcomm/sock.c       |   10 ++--
 net/bluetooth/sco.c               |   10 ++--
 net/caif/caif_socket.c            |   17 +++---
 net/can/bcm.c                     |    7 ++-
 net/can/raw.c                     |    7 ++-
 net/core/sock.c                   |   13 +++--
 net/dccp/proto.c                  |    7 ++-
 net/decnet/af_decnet.c            |    7 ++-
 net/ieee802154/socket.c           |   21 ++++----
 net/ipv4/af_inet.c                |   11 ++--
 net/ipv4/ping.c                   |    7 ++-
 net/ipv4/raw.c                    |    7 ++-
 net/ipv4/tcp.c                    |    7 ++-
 net/ipv4/udp.c                    |    9 ++--
 net/ipv4/udp_impl.h               |    4 +-
 net/ipv6/ping.c                   |    3 +-
 net/ipv6/raw.c                    |    8 ++-
 net/ipv6/udp.c                    |   10 ++--
 net/ipv6/udp_impl.h               |    7 ++-
 net/ipx/af_ipx.c                  |    7 ++-
 net/irda/af_irda.c                |   29 +++++-----
 net/iucv/af_iucv.c                |    8 +--
 net/key/af_key.c                  |    6 +--
 net/l2tp/l2tp_ip.c                |    4 +-
 net/l2tp/l2tp_ppp.c               |    7 ++-
 net/llc/af_llc.c                  |    7 ++-
 net/netlink/af_netlink.c          |    6 +--
 net/netrom/af_netrom.c            |    7 ++-
 net/nfc/llcp_sock.c               |    8 +--
 net/nfc/rawsock.c                 |    7 ++-
 net/packet/af_packet.c            |   11 ++--
 net/phonet/datagram.c             |    8 ++-
 net/phonet/pep.c                  |    8 ++-
 net/phonet/socket.c               |    6 +--
 net/rds/rds.h                     |    7 ++-
 net/rds/recv.c                    |    4 +-
 net/rds/send.c                    |    3 +-
 net/rose/af_rose.c                |    7 ++-
 net/rxrpc/af_rxrpc.c              |    7 ++-
 net/rxrpc/ar-internal.h           |   10 ++--
 net/rxrpc/ar-output.c             |   20 +++----
 net/rxrpc/ar-recvmsg.c            |    4 +-
 net/sctp/socket.c                 |    8 ++-
 net/socket.c                      |   78 +++++----------------------
 net/tipc/socket.c                 |  105 ++++++++++++++++++-------------------
 net/unix/af_unix.c                |   50 ++++++++----------
 net/vmw_vsock/af_vsock.c          |   20 ++++---
 net/vmw_vsock/vmci_transport.c    |    3 +-
 net/x25/af_x25.c                  |    6 +--
 72 files changed, 339 insertions(+), 468 deletions(-)

-- 
1.7.9.5
