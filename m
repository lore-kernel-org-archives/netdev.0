From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/2 net-next v2] Bring sizeof(net_device) down to < 2K bytes
Date: Fri, 10 Apr 2015 15:52:36 +0200
Message-ID: <cover.1428672434.git.tgraf@suug.ch>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	daniel@iogearbox.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33621 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933781AbbDJNws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 09:52:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The size of struct net_device crossed the 2K boundary a while ago which
is a waste in combination with many net namespaces. This series brings
the size of struct net_device down to well below 2K in total size with
a typical configuration. Some reserves a several holes leave room for
further expansion.

Before:
/* size: 2176, cachelines: 34, members: 121 */

After:
/* size: 1984, cachelines: 31, members: 120 */


Thomas Graf (2):
  e1000e: Move pm_qos_req to e1000e adapter
  net_device: Reorder members to fill holes

 drivers/net/ethernet/intel/e1000e/e1000.h  |  1 +
 drivers/net/ethernet/intel/e1000e/netdev.c |  8 +++---
 include/linux/netdevice.h                  | 46 ++++++++++++++----------------
 3 files changed, 26 insertions(+), 29 deletions(-)

---
v2:
 - Moved pm_qos_req to e1000e adapter entirely as suggested by Daniel
 - Dropped patch 2 based on comment from Eric. __alignof__ is not
   reliable to derive alignment of kmalloc returned pointer.
