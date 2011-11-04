From: Zhao Chenhui <chenhui.zhao@freescale.com>
Subject: [PATCH 1/7] powerpc/85xx: re-enable timebase sync disabled by KEXEC patch
Date: Fri, 4 Nov 2011 20:16:41 +0800
Message-ID: <1320409001-14165-1-git-send-email-chenhui.zhao@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <leoli@freescale.com>, <chenhui.zhao@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe001.messaging.microsoft.com ([213.199.154.204]:39781
	"EHLO AM1EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754077Ab1KDMQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 08:16:40 -0400
Received: from mail31-am1 (localhost.localdomain [127.0.0.1])	by
 mail31-am1-R.bigfish.com (Postfix) with ESMTP id 66A8A12E8190	for
 <netdev@vger.kernel.org>; Fri,  4 Nov 2011 12:16:31 +0000 (UTC)
Received: from AM1EHSMHS001.bigfish.com (unknown [10.3.201.243])	by
 mail31-am1.bigfish.com (Postfix) with ESMTP id D6347104805E	for
 <netdev@vger.kernel.org>; Fri,  4 Nov 2011 12:16:30 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yang <leoli@freescale.com>

The timebase sync is not only necessary when using KEXEC. It should also
be used by normal boot up and cpu hotplug. Remove the ifdef added by
the KEXEC patch.

Signed-off-by: Jin Qing <b24347@freescale.com>
Signed-off-by: Li Yang <leoli@freescale.com>
---
 arch/powerpc/platforms/85xx/smp.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/platforms/85xx/smp.c b/arch/powerpc/platforms/85xx/smp.c
index 5b9b901..9b0de9c 100644
--- a/arch/powerpc/platforms/85xx/smp.c
+++ b/arch/powerpc/platforms/85xx/smp.c
@@ -113,10 +113,8 @@ smp_85xx_kick_cpu(int nr)
 
 struct smp_ops_t smp_85xx_ops = {
 	.kick_cpu = smp_85xx_kick_cpu,
-#ifdef CONFIG_KEXEC
 	.give_timebase	= smp_generic_give_timebase,
 	.take_timebase	= smp_generic_take_timebase,
-#endif
 };
 
 #ifdef CONFIG_KEXEC
-- 
1.6.4.1
