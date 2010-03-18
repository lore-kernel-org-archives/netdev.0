From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 0/2] iproute2: Introduce new commands for L2TPv3 unmanaged
	tunnels
Date: Thu, 18 Mar 2010 18:14:16 +0000
Message-ID: <20100318181416.6862.60894.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48171 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752060Ab0CRSOR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 14:14:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new iproute2 commands for L2TPv3 unmanaged tunnels. It requires
L2TPv3 kernel support, patches for which have been submitted to netdev
for review. These iproute2 changes should not be pulled into iproute2
until the kernel support is accepted. I am posting the iproute2 code
now to let people play with L2TPv3 unmanaged tunnels.

To create an L2TPv3 ethernet pseudowire between local host 192.168.1.1
and peer 192.168.1.2, using IP addresses 10.5.1.1 and 10.5.1.2 for the
tunnel endpoints:-

# modprobe l2tp_eth
# modprobe l2tp_netlink

# ip l2tp add tunnel tunnel_id 1 peer_tunnel_id 1 udp_sport 5000 \
  udp_dport 5000 encap udp local 192.168.1.1 remote 192.168.1.2
# ip l2tp add session tunnel_id 1 session_id 1 peer_session_id 1
# ifconfig -a
# ip addr add 10.5.1.2/32 peer 10.5.1.1/32 dev l2tpeth0
# ifconfig l2tpeth0 up

Choose IP addresses to be the address of a local IP interface and that
of the remote system. The IP addresses of the l2tpeth0 interface can be
anything suitable.

Repeat the above at the peer, with ports, tunnel/session ids and IP
addresses reversed.  The tunnel and session IDs can be any non-zero
32-bit number, but the values must be reversed at the peer.

Host 1                         Host2
udp_sport=5000                 udp_sport=5001
udp_dport=5001                 udp_dport=5000
tunnel_id=42                   tunnel_id=45
peer_tunnel_id=45              peer_tunnel_id=42
session_id=128                 session_id=5196755
peer_session_id=5196755        peer_session_id=128

When done at both ends of the tunnel, it should be possible to send
data over the tunnel. e.g.

# ping 10.5.1.1

TODO:-

- Add more config params to control offset and sequence number options.
- Update man page to cover the new ip l2tp command set.

---

James Chapman (2):
      iproute2: Add libnl support.
      iproute2: Add support for static L2TPv3 tunnels.



 Makefile             |    2 
 include/linux/l2tp.h |  164 ++++++++++
 ip/Makefile          |    2 
 ip/ip.c              |    3 
 ip/ip_common.h       |    1 
 ip/ipl2tp.c          |  815 ++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 984 insertions(+), 3 deletions(-)
 create mode 100644 include/linux/l2tp.h
 create mode 100644 ip/ipl2tp.c



