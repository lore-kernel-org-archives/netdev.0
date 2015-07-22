From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V3 net-next 5/5] smc: increase / decrease static key
Date: Wed, 22 Jul 2015 10:59:52 +0200
Message-ID: <1437555592-16506-6-git-send-email-ubraun@linux.vnet.ibm.com>
References: <20150715.212837.233151628267116088.davem@davemloft.net>
 <1437555592-16506-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:45238 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933551AbbGVJAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 05:00:17 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 22 Jul 2015 10:00:15 +0100
In-Reply-To: <1437555592-16506-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

To activate the smc-specific hooks in the TCP-code, static key "tcp_have_smc"
is increased and decreased. For now this is done at module load / unload time.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 net/smc/af_smc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index ed62370..8256e17 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -3142,6 +3142,7 @@ static int __init af_smc_init(void)
 	if (rc)
 		goto out_sock;
 
+	static_key_slow_inc(&tcp_have_smc);
 	return 0;
 
 out_sock:
@@ -3154,6 +3155,7 @@ out:
 
 static void __exit af_smc_exit(void)
 {
+	static_key_slow_dec(&tcp_have_smc);
 	ib_unregister_client(&smc_ib_client);
 	sock_unregister(PF_SMC);
 	proto_unregister(&smc_proto);
-- 
2.3.8
