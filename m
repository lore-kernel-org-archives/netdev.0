From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking update: summary (0/5)
Date: Fri, 7 Feb 2003 02:11:09 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302070142050.2174-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@wirex.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following five patches are an updated version of the LSM (Linux 
Security Modules) networking support hooks, submitted for inclusion in 2.5 
mainline.

Since the post last week, the networking hooks have been reworked so that
they are more generalized and do not poke as deeply into network
protocols.

Change summary:

  o The netdevice, skb and ipv4 hooks are gone.

  o The sock_queue_rcv_skb() hook has been encapsulated within 
    sk_filter() as suggested by David Miller.

  o The sk->security field has been removed (use the socket inode field 
    instead, if needed, or infer the value).

  o The sk_filter() calls for TCPv4 and TCPv6 have been relocated so that 
    they are called before skb->dev is cleared (which also fixes a 
    mainline issue).

  o An sk_filter() call was added to SCTP.

  o The default Netlink capability hooks have been inlined so that they do 
    not call out to a module when CONFIG_SECURITY is disabled, per 
    requirements from David Miller.

  o The Netlink hooks now also cover ip6_queue and xfrm_user.


Full diffstat:

 include/linux/security.h       |  429 ++++++++++++++++++++++++++++++++++++++++-
 include/net/sock.h             |   95 ++++++---
 net/core/rtnetlink.c           |    3 
 net/decnet/dn_nsp_in.c         |   29 +-
 net/ipv4/netfilter/ip_queue.c  |    3 
 net/ipv4/tcp_ipv4.c            |    9 
 net/ipv4/xfrm_user.c           |    3 
 net/ipv6/netfilter/ip6_queue.c |    6 
 net/ipv6/tcp_ipv6.c            |   15 -
 net/netlink/af_netlink.c       |    8 
 net/sctp/input.c               |    4 
 net/socket.c                   |   72 ++++++
 net/unix/af_unix.c             |   16 +
 security/Kconfig               |    9 
 security/capability.c          |    2 
 security/dummy.c               |  135 ++++++++++++
 16 files changed, 760 insertions(+), 78 deletions(-)


- James
-- 
James Morris
<jmorris@intercode.com.au>
