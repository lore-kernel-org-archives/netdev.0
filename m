From: Elad Kanfi <eladkan@mellanox.com>
Subject: [PATCH v2 0/2] Net driver bugs fix
Date: Wed, 27 Apr 2016 16:18:28 +0300
Message-ID: <1461763110-15263-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <noamca@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<abrodkin@synopsys.com>, <eladkan@mellanox.com>,
	<talz@mellanox.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0067.outbound.protection.outlook.com ([157.55.234.67]:22944
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751798AbcD0NxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 09:53:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Kanfi <eladkan@mellanox.com>

v2:
Remove code style commit for now.
Code style commit will be added after the bugs fix will be approved.

Summary:
 1. Bug description: TX done interrupts that arrives while interrupts
    are masked, during NAPI poll, will not trigger an interrupt handling.
    Since TX interrupt is of level edge we will lose the TX done interrupt.
    As a result all pending tx frames will get no service.

    Solution: Check if there is a pending tx request after unmasking the
    interrupt and if answer is yes then re-add ourselves to
    the NAPI poll list.

 2. Bug description: CPU-A before sending a frame will set a variable
    to true. CPU-B that executes the tx done interrupt service routine
    might read a non valid value of that variable.

    Solution: Add a memory barrier at the tx sending function.

Elad Kanfi (2):
  net: nps_enet: Sync access to packet sent flag
  net: nps_enet: bug fix - handle lost tx interrupts

 drivers/net/ethernet/ezchip/nps_enet.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)
