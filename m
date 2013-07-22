From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 0/7] net: introduce generic type and helpers for IP address
Date: Mon, 22 Jul 2013 15:05:06 +0800
Message-ID: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755101Ab3GVHF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 03:05:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

As IPv6 becomes popular, more and more subsystems begin to support IPv6,
therefore we need a generic IP address type, in case of duplicates.
Also we will also need some helpers to compare, print, check the generic
IP address.

This patchset introduce a new type union inet_addr as a union of IPv4
and IPv6 address, and some helper functions that will be used by existing
code and in the future VXLAN module.

However, due to ABI limit, we still can't convert union nf_inet_addr
to union inet_addr.

Signed-off-by: Cong Wang <amwang@redhat.com>

Changes since RFC:
* rebase these patches on top of Daniel's
* rename inet_pton() to simple_inet_pton()
* fix the simple_inet_pton() API
* make inet_addr_equal() non-inline
* add two more patches

Cong Wang (7):
  net: introduce generic union inet_addr
  net: introduce generic simple_inet_pton()
  inetpeer: use generic union inet_addr
  sunrpc: use generic union inet_addr
  fs: use generic union inet_addr and help functions
  sctp: use generic union inet_addr
  selinux: use generic union inet_addr

 Documentation/printk-formats.txt   |   20 ++--
 drivers/net/netconsole.c           |   22 ++--
 fs/cifs/connect.c                  |   39 ++-----
 fs/dlm/lowcomms.c                  |   24 +---
 fs/nfs/client.c                    |   94 +-------------
 fs/nfs/nfs4filelayoutdev.c         |   37 +-----
 fs/nfs/super.c                     |   31 +----
 include/linux/lsm_audit.h          |   16 +--
 include/linux/netpoll.h            |    9 +--
 include/linux/sunrpc/addr.h        |  118 +-----------------
 include/net/inet_addr.h            |  106 ++++++++++++++++
 include/net/inetpeer.h             |   29 ++---
 include/net/sctp/sctp.h            |   22 ++--
 include/net/sctp/sm.h              |    4 +-
 include/net/sctp/structs.h         |  132 +++++++++-----------
 lib/vsprintf.c                     |   29 ++---
 net/core/netpoll.c                 |   86 +++++--------
 net/core/utils.c                   |   84 +++++++++++++
 net/ipv4/inetpeer.c                |   37 ++++--
 net/ipv4/tcp_metrics.c             |   92 ++++++--------
 net/sctp/associola.c               |   32 +++---
 net/sctp/bind_addr.c               |   61 +++------
 net/sctp/endpointola.c             |   12 +-
 net/sctp/input.c                   |   56 ++++----
 net/sctp/ipv6.c                    |  240 ++++++++++++++++--------------------
 net/sctp/outqueue.c                |    4 +-
 net/sctp/proc.c                    |   10 +-
 net/sctp/protocol.c                |  204 ++++++++++++-------------------
 net/sctp/sm_make_chunk.c           |   54 ++++----
 net/sctp/sm_sideeffect.c           |    2 +-
 net/sctp/sm_statefuns.c            |   23 +---
 net/sctp/socket.c                  |  130 +++++++++++---------
 net/sctp/transport.c               |   12 +-
 net/sctp/ulpevent.c                |    2 +-
 security/lsm_audit.c               |   16 ++--
 security/selinux/hooks.c           |   73 ++++-------
 security/selinux/include/netnode.h |    4 +-
 security/selinux/include/objsec.h  |    7 +-
 security/selinux/netnode.c         |  102 +++++-----------
 39 files changed, 878 insertions(+), 1197 deletions(-)
 create mode 100644 include/net/inet_addr.h

-- 
1.7.7.6
