From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: introduction (0/8)
Date: Fri, 31 Jan 2003 09:42:24 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301310916040.31382-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Following this email will be the LSM (Linux Security Modules) networking
code split up into eight patches for submission to the mainline kernel.

Since the last submission of these patches, improvements have been made to
the LSM code based on feedback from maintainers and the community.  The
LSM hooks are now implemented as static inlines in the main kernel, and
may be compiled out, while the LSM networking code is now generally
configurable via CONFIG_SECURITY_NETWORK.  This work was done by Stephen
Smalley.

The configuration exceptions are the two Netlink hooks and the
ip_decode_options() hook, which always need to be present as they
implement default capabilities logic.  The rest of the hooks disappear
when not enabled.

Cumulative summary:

 include/linux/ip.h            |    1 
 include/linux/netdevice.h     |    4 
 include/linux/security.h      |  807 +++++++++++++++++++++++++++++++++++++++++-
 include/linux/skbuff.h        |    3 
 include/linux/tcp.h           |   11 
 include/net/sock.h            |   16 
 include/net/tcp.h             |   26 +
 net/core/datagram.c           |    5 
 net/core/dev.c                |    3 
 net/core/rtnetlink.c          |    3 
 net/core/skbuff.c             |   16 
 net/core/sock.c               |    6 
 net/ipv4/ah.c                 |    2 
 net/ipv4/ip_fragment.c        |    7 
 net/ipv4/ip_gre.c             |    3 
 net/ipv4/ip_options.c         |    5 
 net/ipv4/ip_output.c          |    3 
 net/ipv4/ipip.c               |    4 
 net/ipv4/ipmr.c               |    4 
 net/ipv4/netfilter/ip_queue.c |    3 
 net/ipv4/syncookies.c         |    3 
 net/ipv4/tcp_ipv4.c           |    8 
 net/ipv4/tcp_minisocks.c      |    6 
 net/netlink/af_netlink.c      |    8 
 net/socket.c                  |   72 +++
 net/unix/af_unix.c            |   16 
 security/Kconfig              |    9 
 security/capability.c         |   30 +
 security/dummy.c              |  267 +++++++++++++
 29 files changed, 1334 insertions(+), 17 deletions(-)


(Note that more information on LSM can be found at 
http://lsm.immunix.org/).


- James
-- 
James Morris
<jmorris@intercode.com.au>
