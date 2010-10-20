From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH 0/3] tproxy fixes for current upstream code
Date: Wed, 20 Oct 2010 13:21:42 +0200
Message-ID: <20101020112142.6538.25550.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series fix a handful of issues which have been found in the
current upstream IPv4 tproxy code:

  * an issue with how port redirection interacts with TCP TIME_WAIT sockets
  * UDP socket lookup fixes so that now it prefers connected sockets, etc.
  * fix for a bind hash issue which could trigger crashes when port redirection
    was used.

---

Balazs Scheidler (2):
      tproxy: kick out TIME_WAIT sockets in case a new connection comes in with the same tuple
      tproxy: add lookup type checks for UDP in nf_tproxy_get_sock_v4()

KOVACS Krisztian (1):
      tproxy: fix hash locking issue when using port redirection in __inet_inherit_port()


 include/net/inet_hashtables.h          |    2 -
 include/net/netfilter/nf_tproxy_core.h |  120 +++++++++++++++++++++++++++++++-
 net/dccp/ipv4.c                        |   10 ++-
 net/dccp/ipv6.c                        |   10 ++-
 net/ipv4/inet_hashtables.c             |   28 +++++++
 net/ipv4/tcp_ipv4.c                    |   10 ++-
 net/ipv6/tcp_ipv6.c                    |   12 ++-
 net/netfilter/nf_tproxy_core.c         |   35 ---------
 net/netfilter/xt_TPROXY.c              |   68 +++++++++++++++++-
 net/netfilter/xt_socket.c              |    2 -
 10 files changed, 238 insertions(+), 59 deletions(-)

-- 
KOVACS Krisztian

