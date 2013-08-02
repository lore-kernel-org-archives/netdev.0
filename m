From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v2 0/8] net: introduce generic type and helpers for IP address
Date: Fri,  2 Aug 2013 15:14:26 +0800
Message-ID: <1375427674-21735-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753923Ab3HBHOy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 03:14:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

As IPv6 becomes popular, more and more subsystems begin to support IPv6,
therefore we need a generic IP address type, in case of duplicates.
Also we will also need some helpers to compare, print, check the generic
IP address.

This patchset introduce a new type union inet_addr as a union of IPv4
and IPv6 address, and struct in_addr_gen for inetpeer and bridge mdb,
plus some helper functions that will be used by existing code and
in the future VXLAN module.

However, due to ABI limit, we still can't convert union nf_inet_addr
to union inet_addr.

Signed-off-by: Cong Wang <amwang@redhat.com>

v1 -> v2:
* introduce another generic IP address type, struct in_addr_gen
* convert bridge multicast code too
* complete the smack part

RFC -> v1:
* rebase these patches on top of Daniel's
* rename inet_pton() to simple_inet_pton()
* fix the simple_inet_pton() API
* make inet_addr_equal() non-inline
* add two more patches

Cong Wang (8):
  net: introduce generic union inet_addr
  net: introduce generic simple_inet_pton()
  inetpeer: use generic struct in_addr_gen
  bridge: use generic struct in_addr_gen
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
 include/linux/lsm_audit.h          |   19 +---
 include/linux/netpoll.h            |    9 +--
 include/linux/sunrpc/addr.h        |  118 +-----------------
 include/net/inet_addr.h            |  128 +++++++++++++++++++
 include/net/inetpeer.h             |   25 +---
 include/net/sctp/sctp.h            |   22 ++--
 include/net/sctp/sm.h              |    4 +-
 include/net/sctp/structs.h         |  132 +++++++++-----------
 lib/vsprintf.c                     |   29 ++---
 net/bridge/br_mdb.c                |   53 ++++----
 net/bridge/br_multicast.c          |   65 ++++------
 net/bridge/br_private.h            |    9 +-
 net/core/netpoll.c                 |   86 +++++--------
 net/core/utils.c                   |   84 +++++++++++++
 net/ipv4/inetpeer.c                |   33 +++--
 net/ipv4/tcp_metrics.c             |   74 +++++-------
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
 security/lsm_audit.c               |   58 +++++-----
 security/selinux/hooks.c           |  130 +++++++++----------
 security/selinux/include/netnode.h |    4 +-
 security/selinux/include/objsec.h  |    7 +-
 security/selinux/netnode.c         |  102 +++++-----------
 security/smack/smack_lsm.c         |   19 ++--
 43 files changed, 1008 insertions(+), 1311 deletions(-)
 create mode 100644 include/net/inet_addr.h

-- 
1.7.7.6
