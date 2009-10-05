From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 15/15] igb: add flushes between RAR writes when
	setting mac address
Date: Mon, 05 Oct 2009 09:36:01 -0700
Message-ID: <20091005163601.32487.87871.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:45021
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753942AbZJEQiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:38:11 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There are some switches that will do write combining when they see two
sequential regions written. In order to avoid any possible write combining
issues it is necessary to add a flush after writing each piece of a rar
register.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_mac.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 4969a5b..2ad358a 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -247,8 +247,15 @@ void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 	if (rar_low || rar_high)
 		rar_high |= E1000_RAH_AV;
 
+	/*
+	 * Some bridges will combine consecutive 32-bit writes into
+	 * a single burst write, which will malfunction on some parts.
+	 * The flushes avoid this.
+	 */
 	wr32(E1000_RAL(index), rar_low);
+	wrfl();
 	wr32(E1000_RAH(index), rar_high);
+	wrfl();
 }
 
 /**

