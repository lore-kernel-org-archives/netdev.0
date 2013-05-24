From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH next-next v4 0/2] MPLS: Add limited GSO support
Date: Fri, 24 May 2013 15:51:33 +0900
Message-ID: <1369378295-17779-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

In the case where a non-MPLS packet is received and an MPLS stack is
added it may well be the case that the original skb is GSO but the
NIC used for transmit does not support GSO of MPLS packets.

The aim of this short series is to provide GSO in software for MPLS packets
whose skbs are GSO.

Change since v4:

Update first patch of the series to use 16 bits for all *_headers
rather than just inner_*_headers

Simon Horman (2):
  net: Use 16bits for *_headers fields of struct skbuff
  MPLS: Add limited GSO support

 include/linux/netdev_features.h |   4 +-
 include/linux/netdevice.h       |   2 +
 include/linux/skbuff.h          | 123 ++++------------------------------------
 net/Kconfig                     |   1 +
 net/Makefile                    |   1 +
 net/core/dev.c                  |   4 ++
 net/core/ethtool.c              |   1 +
 net/ipv4/af_inet.c              |   1 +
 net/ipv4/tcp.c                  |   1 +
 net/ipv4/udp.c                  |   2 +-
 net/ipv6/ip6_offload.c          |   1 +
 net/ipv6/udp_offload.c          |   3 +-
 net/mpls/Kconfig                |   9 +++
 net/mpls/Makefile               |   4 ++
 net/mpls/mpls_gso.c             | 108 +++++++++++++++++++++++++++++++++++
 15 files changed, 149 insertions(+), 116 deletions(-)
 create mode 100644 net/mpls/Kconfig
 create mode 100644 net/mpls/Makefile
 create mode 100644 net/mpls/mpls_gso.c

-- 
1.8.2.1
