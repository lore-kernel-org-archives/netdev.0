From: Cong Wang <amwang@redhat.com>
Subject: [RFC Patch net-next 0/5] net: introduce generic type and helpers for IP address
Date: Thu, 27 Jun 2013 14:43:13 +0800
Message-ID: <1372315398-19683-1-git-send-email-amwang@redhat.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810Ab3F0Gna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 02:43:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As IPv6 becomes popular, more and more subsystems begin to support IPv6,
therefore we need a generic IP address type, in case of duplicates.
Also we will also need some helpers to compare, print, check the generic
IP address.

This patchset introduce a new type union inet_addr as a union of IPv4
and IPv6 address, and some helper functions that will be used by existing
code and in the future VXLAN module.

This patchset only does compile test, since it is still RFC.

Cong Wang (5):
  net: introduce generic union inet_addr
  net: introduce generic inet_pton()
  inetpeer: use generic union inet_addr
  sunrpc: use generic union inet_addr
  nfs,cifs: abstract generic inet_addr_equal_strict()

 Documentation/printk-formats.txt |    9 ++
 drivers/net/netconsole.c         |   22 +++---
 fs/cifs/connect.c                |   38 ++-------
 fs/dlm/lowcomms.c                |   24 +-----
 fs/nfs/client.c                  |   94 +--------------------
 fs/nfs/nfs4filelayoutdev.c       |   37 +--------
 fs/nfs/super.c                   |   31 +-------
 include/linux/netpoll.h          |    9 +--
 include/linux/sunrpc/addr.h      |  119 ++-------------------------
 include/net/inet_addr.h          |  164 ++++++++++++++++++++++++++++++++++++++
 include/net/inetpeer.h           |   29 ++-----
 lib/vsprintf.c                   |   18 ++++-
 net/core/netpoll.c               |   74 ++++++-----------
 net/ipv4/inetpeer.c              |   35 +++++---
 net/ipv4/tcp_metrics.c           |   92 +++++++++-------------
 15 files changed, 327 insertions(+), 468 deletions(-)
 create mode 100644 include/net/inet_addr.h

-- 
1.7.7.6
