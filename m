From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 30 Sep 2009 17:01:01 -0700 (PDT)
Message-ID: <20090930.170101.26180575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37336
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754927AbZJAAAl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2009 20:00:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Make optlen in setsockopt unsigned, providing type level
   protection against several "< 0" issues that tend to
   be (wrongly) addressed at the implementation level.

2) sock_wfree() can race with a cpu freeing up a socket,
   fix from Eric Dumazet.  Lots of people are hitting this
   lately.

3) Off-by-one in ipv6 SIT tunnel driver, fix from Sascha Hlusiak

4) phonet does double mutex unlock, fix from R=E9mi Denis-Courmont.

5) ax25 sets up destructor callback pointer before state is ready,
   fix from Jarek Poplawski

6) TX timestamping stopped working on hw accelerated VLANs a few
   releases ago, oops, fix from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit 9c1fe834c1bd7725b411055c66886b64c928=
083d:
  Linus Torvalds (1):
        Merge branch 'pm-fixes' of git://git.kernel.org/.../rafael/susp=
end-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      net: Make setsockopt() optlen be unsigned.

Eric Dumazet (2):
      net: Fix sock_wfree() race
      net: restore tx timestamping for accelerated vlans

Jarek Poplawski (1):
      ax25: Fix possible oops in ax25_make_new

R=E9mi Denis-Courmont (1):
      Phonet: fix mutex imbalance

Sascha Hlusiak (1):
      sit: fix off-by-one in ipip6_tunnel_get_prl

 drivers/atm/ambassador.c           |    8 -----
 drivers/atm/eni.c                  |    2 +-
 drivers/atm/firestream.c           |    2 +-
 drivers/atm/fore200e.c             |    2 +-
 drivers/atm/horizon.c              |    2 +-
 drivers/atm/iphase.c               |    2 +-
 drivers/atm/zatm.c                 |    2 +-
 drivers/isdn/mISDN/socket.c        |    2 +-
 drivers/net/pppol2tp.c             |    2 +-
 include/linux/atmdev.h             |    2 +-
 include/linux/mroute.h             |    4 +-
 include/linux/mroute6.h            |    4 +-
 include/linux/net.h                |    8 ++--
 include/linux/netfilter.h          |    4 +-
 include/net/compat.h               |    4 +-
 include/net/inet_connection_sock.h |    6 ++--
 include/net/ip.h                   |    4 +-
 include/net/ipv6.h                 |    4 +-
 include/net/sctp/structs.h         |    4 +-
 include/net/sock.h                 |   12 +++---
 include/net/tcp.h                  |    4 +-
 include/net/udp.h                  |    2 +-
 net/atm/common.c                   |    2 +-
 net/atm/common.h                   |    2 +-
 net/atm/pvc.c                      |    2 +-
 net/atm/svc.c                      |    2 +-
 net/ax25/af_ax25.c                 |    4 +-
 net/bluetooth/hci_sock.c           |    2 +-
 net/bluetooth/l2cap.c              |    4 +-
 net/bluetooth/rfcomm/sock.c        |    4 +-
 net/bluetooth/sco.c                |    2 +-
 net/can/raw.c                      |    2 +-
 net/compat.c                       |   12 +++---
 net/core/dev.c                     |    6 ++--
 net/core/sock.c                    |   27 +++++++++------
 net/dccp/dccp.h                    |    4 +-
 net/dccp/proto.c                   |   10 +++---
 net/decnet/af_decnet.c             |    6 ++--
 net/ieee802154/dgram.c             |    2 +-
 net/ieee802154/raw.c               |    2 +-
 net/ipv4/inet_connection_sock.c    |    2 +-
 net/ipv4/ip_sockglue.c             |    6 ++--
 net/ipv4/ipmr.c                    |    2 +-
 net/ipv4/raw.c                     |    6 ++--
 net/ipv4/tcp.c                     |    6 ++--
 net/ipv4/udp.c                     |    6 ++--
 net/ipv4/udp_impl.h                |    4 +-
 net/ipv6/ip6mr.c                   |    2 +-
 net/ipv6/ipv6_sockglue.c           |    6 ++--
 net/ipv6/raw.c                     |    6 ++--
 net/ipv6/sit.c                     |    2 +-
 net/ipv6/udp.c                     |    4 +-
 net/ipv6/udp_impl.h                |    4 +-
 net/ipx/af_ipx.c                   |    2 +-
 net/irda/af_irda.c                 |    2 +-
 net/iucv/af_iucv.c                 |    2 +-
 net/llc/af_llc.c                   |    2 +-
 net/netfilter/nf_sockopt.c         |    4 +-
 net/netlink/af_netlink.c           |    2 +-
 net/netrom/af_netrom.c             |    2 +-
 net/packet/af_packet.c             |    2 +-
 net/phonet/pep.c                   |    2 +-
 net/phonet/socket.c                |    1 -
 net/rds/af_rds.c                   |    2 +-
 net/rose/af_rose.c                 |    2 +-
 net/rxrpc/af_rxrpc.c               |    2 +-
 net/sctp/socket.c                  |   62 +++++++++++++++++++---------=
--------
 net/socket.c                       |    2 +-
 net/tipc/socket.c                  |    2 +-
 net/x25/af_x25.c                   |    2 +-
 70 files changed, 166 insertions(+), 166 deletions(-)
