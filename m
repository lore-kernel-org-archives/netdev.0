From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH RFC v1 0/7] NCSI Support
Date: Tue,  6 Oct 2015 14:09:42 +1100
Message-ID: <1444100989-3437-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, davem@davemloft.net,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:54344 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbbJFD6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 23:58:13 -0400
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 6 Oct 2015 13:58:11 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 22DDA2CE8055
	for <netdev@vger.kernel.org>; Tue,  6 Oct 2015 14:58:10 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t963vvZ238862950
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 14:58:05 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t963vblv007947
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 14:57:37 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is prototype requesting for comments.

This series of patches intends to support NCSI stack, which is specified by
DSP0222. One NCSI enabled interface potentially connects to multiple packages
and channels, but there is one active channel at once when hardware arbitration
is disabled. No hardware arbitration isn't supported by this patchset:

   * NIC driver registers NCSI device when the network device is registered. The
     NCSI device should be started when bringing up the interface so that the
     active channel can be choosed from the available channels and starts to provide
     service.
   * When NCSI AEN packet is received from currently active channel for sake of
     failure, another active channel is tried to choosed to accomplish the failover.
   * Reserved netlink interface for NCSI is supported so that userland can retrieve
     NCSI information or configure from/to NCSI channels.
   * The first user of NCSI stack is faraday driver (ftgmac100.c).

Gavin Shan (7):
  net/ncsi: Resource management
  net/ncsi: Packet handler
  net/ncsi: Manage NCSI device
  net/ncsi: Netlink support
  net/faraday: Replace use_nc_si with use_ncsi
  net/faraday: Enable NCSI interface
  net/faraday: Enable offload checksum according to device-tree

 drivers/net/ethernet/faraday/ftgmac100.c |  109 ++-
 include/net/ncsi.h                       |   59 ++
 include/uapi/linux/if_ether.h            |    1 +
 include/uapi/linux/ncsi.h                |  200 +++++
 include/uapi/linux/netlink.h             |    1 +
 net/Kconfig                              |    1 +
 net/Makefile                             |    1 +
 net/ncsi/Kconfig                         |   10 +
 net/ncsi/Makefile                        |    5 +
 net/ncsi/internal.h                      |  165 +++++
 net/ncsi/ncsi-aen.c                      |  197 +++++
 net/ncsi/ncsi-cmd.c                      |  380 ++++++++++
 net/ncsi/ncsi-manage.c                   |  914 +++++++++++++++++++++++
 net/ncsi/ncsi-netlink.c                  | 1042 ++++++++++++++++++++++++++
 net/ncsi/ncsi-pkt.h                      |  391 ++++++++++
 net/ncsi/ncsi-rsp.c                      | 1167 ++++++++++++++++++++++++++++++
 net/ncsi/ncsi.c                          |   49 ++
 17 files changed, 4661 insertions(+), 31 deletions(-)
 create mode 100644 include/net/ncsi.h
 create mode 100644 include/uapi/linux/ncsi.h
 create mode 100644 net/ncsi/Kconfig
 create mode 100644 net/ncsi/Makefile
 create mode 100644 net/ncsi/internal.h
 create mode 100644 net/ncsi/ncsi-aen.c
 create mode 100644 net/ncsi/ncsi-cmd.c
 create mode 100644 net/ncsi/ncsi-manage.c
 create mode 100644 net/ncsi/ncsi-netlink.c
 create mode 100644 net/ncsi/ncsi-pkt.h
 create mode 100644 net/ncsi/ncsi-rsp.c
 create mode 100644 net/ncsi/ncsi.c

-- 
2.1.0
