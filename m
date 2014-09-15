From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net 0/2] Fix randconfig errros in bnx2i/bnx2fc caused by IPV6
Date: Mon, 15 Sep 2014 13:45:19 -0700
Message-ID: <1410813921-24400-1-git-send-email-anish@chelsio.com>
Cc: linux-scsi@vger.kernel.org, davem@davemloft.net,
	JBottomley@parallels.com, mchan@broadcom.com,
	eddie.wai@broadcom.com, rdunlap@infradead.org, jim.epost@gmail.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:52012
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756149AbaIOUrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 16:47:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just like CNIC bnx2i/bnx2fc also have their tristate dependent on IPV6, however
using the same solution as CNIC can cause recursive dependecies during make.

Based on suggestions by Randy Dunlap, SCSI_NETLINK now depends on NET instead
 of selecting NET. Second patch fixes the actual randconfig error.

Entire thread can be followed here : https://lkml.org/lkml/2014/9/9/500
-Anish

Fixes: c99d667e8527 ("cnic : Cleanup CONFIG_IPV6 & VLAN check")

Anish Bhatt (2):
  scsi_netlink : Make SCSI_NETLINK dependent on NET instead of selecting
    NET
  bnx2i/bnx2fc : fix randconfig error

 drivers/scsi/Kconfig        | 2 +-
 drivers/scsi/bnx2fc/Kconfig | 1 +
 drivers/scsi/bnx2i/Kconfig  | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

-- 
2.1.0
