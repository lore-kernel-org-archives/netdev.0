From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 2/5] powerpc/qe: Implement qe_alive_during_sleep() helper
 function
Date: Thu, 27 Aug 2009 21:35:50 +0400
Message-ID: <20090827173550.GB1580@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Timur Tabi <timur@freescale.com>,
	Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:17549 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751586AbZH0Rft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 13:35:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some CPUs (i.e. MPC8569) QE shuts down completely during sleep,
drivers may want to know that to reinitialize registers and buffer
descriptors.

This patch implements qe_alive_during_sleep() helper function, so far
it just checks if MPC8569-compatible power management controller is
present, which is a sign that QE turns off during sleep.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 arch/powerpc/include/asm/qe.h   |    1 +
 arch/powerpc/sysdev/qe_lib/qe.c |   13 +++++++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/qe.h b/arch/powerpc/include/asm/qe.h
index e8232bb..20c0b07 100644
--- a/arch/powerpc/include/asm/qe.h
+++ b/arch/powerpc/include/asm/qe.h
@@ -163,6 +163,7 @@ int qe_get_snum(void);
 void qe_put_snum(u8 snum);
 unsigned int qe_get_num_of_risc(void);
 unsigned int qe_get_num_of_snums(void);
+int qe_alive_during_sleep(void);
 
 /* we actually use cpm_muram implementation, define this for convenience */
 #define qe_muram_init cpm_muram_init
diff --git a/arch/powerpc/sysdev/qe_lib/qe.c b/arch/powerpc/sysdev/qe_lib/qe.c
index f485d5a..a765f9c 100644
--- a/arch/powerpc/sysdev/qe_lib/qe.c
+++ b/arch/powerpc/sysdev/qe_lib/qe.c
@@ -65,6 +65,19 @@ static unsigned int qe_num_of_snum;
 
 static phys_addr_t qebase = -1;
 
+int qe_alive_during_sleep(void)
+{
+	static int ret = -1;
+
+	if (ret != -1)
+		return ret;
+
+	ret = !of_find_compatible_node(NULL, NULL, "fsl,mpc8569-pmc");
+
+	return ret;
+}
+EXPORT_SYMBOL(qe_alive_during_sleep);
+
 phys_addr_t get_qe_base(void)
 {
 	struct device_node *qe;
-- 
1.6.3.3

