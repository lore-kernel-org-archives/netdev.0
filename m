From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] drivers/base: export (un)register_memory_notifier
Date: Fri, 1 Feb 2008 17:16:31 +0100
Message-ID: <200802011716.32511.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Jan-Bernd Themann" <themann@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	Christoph Raisch <RAISCH@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Badari Pulavarty <pbadari@us.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: "linux-kernel" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:64648 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023AbYBAQQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 11:16:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers like eHEA need memory notifiers in order to 
update their internal DMA memory map when memory is added
to or removed from the system.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
 Comment: eHEA patches that exploit these functions will follow


 drivers/base/memory.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 7ae413f..1e1bd4c 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -52,11 +52,13 @@ int register_memory_notifier(struct notifier_block *nb)
 {
         return blocking_notifier_chain_register(&memory_chain, nb);
 }
+EXPORT_SYMBOL(register_memory_notifier);
 
 void unregister_memory_notifier(struct notifier_block *nb)
 {
         blocking_notifier_chain_unregister(&memory_chain, nb);
 }
+EXPORT_SYMBOL(unregister_memory_notifier);
 
 /*
  * register_memory - Setup a sysfs device for a memory block
-- 
1.5.2

