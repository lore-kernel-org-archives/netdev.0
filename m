From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] sfc: Suppress warning about combining enum
 flags by gcc 4.5
Date: Tue, 17 May 2011 19:48:41 +0100
Message-ID: <1305658121.2848.29.camel@bwh-desktop>
References: <20110517.141446.140687548350861625.davem@davemloft.net>
	 <1305656319.2848.28.camel@bwh-desktop>
	 <20110517.142350.81148594119844192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:48678 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756125Ab1EQSso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 14:48:44 -0400
In-Reply-To: <20110517.142350.81148594119844192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc 4.5 warns about switch statements on enumerated types containing
case values that are a bitwise-or of two enumerators for that type.
The use of enumerators as flags is common practice, so I think the
warning is wrong.  Keep the compiler quiet by casting the switch
value.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Will this do?

Ben.

 drivers/net/sfc/mcdi_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/mcdi_mac.c b/drivers/net/sfc/mcdi_mac.c
index 50c2077..316745b 100644
--- a/drivers/net/sfc/mcdi_mac.c
+++ b/drivers/net/sfc/mcdi_mac.c
@@ -32,7 +32,7 @@ static int efx_mcdi_set_mac(struct efx_nic *efx)
 		(1 << MC_CMD_SET_MAC_IN_REJECT_UNCST_LBN);
 	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_REJECT, reject);
 
-	switch (efx->wanted_fc) {
+	switch ((unsigned)efx->wanted_fc) {
 	case EFX_FC_RX | EFX_FC_TX:
 		fcntl = MC_CMD_FCNTL_BIDIR;
 		break;
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

