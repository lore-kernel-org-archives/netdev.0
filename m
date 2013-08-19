From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 0/9] net: introduce generic type and helpers for IP address
Date: Mon, 19 Aug 2013 18:14:29 +0800
Message-ID: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808Ab3HSKOr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 06:14:47 -0400
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

v2 -> v3:
* introduce sockaddr_*() helper functions as well
* split the first patch into two
* rebase on to the latest net-next

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

Cong Wang (9):
  net: introduce generic union inet_addr
  net: rename '%pIS' to '%pIA' for union inet_addr
  net: introduce generic simple_inet_pton()
  inetpeer: use generic struct in_addr_gen
  bridge: use generic struct in_addr_gen
  sunrpc: use generic union inet_addr
  fs: use generic union inet_addr and help functions
  sctp: use generic union inet_addr
  selinux: use generic union inet_addr

 Documentation/printk-formats.txt   |   20 ++--
 drivers/net/netconsole.c           |   22 ++--
 fs/cifs/connect.c                  |   54 ++------
 fs/dlm/lowcomms.c                  |   24 +---
 fs/lockd/clntlock.c                |    2 +-
 fs/lockd/host.c                    |    8 +-
 fs/lockd/mon.c                     |    2 +-
 fs/lockd/svcsubs.c                 |    2 +-
 fs/nfs/client.c                    |  113 +-----------------
 fs/nfs/nfs4client.c                |    2 +-
 fs/nfs/nfs4filelayoutdev.c         |   37 +-----
 fs/nfs/nfs4namespace.c             |    2 +-
 fs/nfs/super.c                     |   37 +-----
 fs/nfsd/nfs4state.c                |    6 +-
 fs/nfsd/nfscache.c                 |    8 +-
 include/linux/lsm_audit.h          |   19 +---
 include/linux/netpoll.h            |    9 +--
 include/linux/sunrpc/addr.h        |  131 +-------------------
 include/net/inet_addr.h            |  160 ++++++++++++++++++++++++
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
 net/sunrpc/clnt.c                  |    2 +-
 net/sunrpc/rpcb_clnt.c             |    2 +-
 net/sunrpc/xprtrdma/transport.c    |    4 +-
 net/sunrpc/xprtsock.c              |    8 +-
 security/lsm_audit.c               |   58 +++++-----
 security/selinux/hooks.c           |  130 +++++++++----------
 security/selinux/include/netnode.h |    4 +-
 security/selinux/include/objsec.h  |    7 +-
 security/selinux/netnode.c         |  102 +++++-----------
 security/smack/smack_lsm.c         |   19 ++--
 55 files changed, 1063 insertions(+), 1389 deletions(-)
 create mode 100644 include/net/inet_addr.h

-- 
1.7.7.6
