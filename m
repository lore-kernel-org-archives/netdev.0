From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v4 0/4] xen-netback: support for control ring
Date: Fri, 13 May 2016 09:37:25 +0100
Message-ID: <1463128649-20832-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>
To: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:32640 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbcEMIvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 04:51:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My recent patch to import an up-to-date include/xen/interface/io/netif.h
from the Xen Project brought in the necessary definitions to support the
new control shared ring and protocol. This patch series updates xen-netback
to support the new ring.

Patch #1 adds the necessary boilerplate to map the control ring and handle
messages. No implementation of the new protocol is included in this patch
so that it can be kept to a reasonable size.

Patch #2 adds the protocol implementation.

Patch #3 adds support for passing has values calculated by xen-netback to
capable frontends.

Patch #4 adds support for accepting hash values calculated by capable
frontends and using them the set the socket buffer hash.

Paul Durrant (4):
  xen-netback: add control ring boilerplate
  xen-netback: add control protocol implementation
  xen-netback: pass hash value to the frontend
  xen-netback: use hash value from the frontend

 drivers/net/xen-netback/Makefile    |   2 +-
 drivers/net/xen-netback/common.h    |  74 ++++++-
 drivers/net/xen-netback/hash.c      | 384 ++++++++++++++++++++++++++++++++++++
 drivers/net/xen-netback/interface.c | 134 ++++++++++++-
 drivers/net/xen-netback/netback.c   | 249 +++++++++++++++++++++--
 drivers/net/xen-netback/xenbus.c    |  79 +++++++-
 6 files changed, 879 insertions(+), 43 deletions(-)
 create mode 100644 drivers/net/xen-netback/hash.c

-- 
2.1.4
