From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next 2/6] sfc: allow asynchronous MCDI without completion
 function
Date: Thu, 11 Aug 2016 13:01:21 +0100
Message-ID: <59fe3c6a-0483-995b-3c33-5e3afb4ed501@solarflare.com>
References: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:21946 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751148AbcHKM0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 08:26:44 -0400
In-Reply-To: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index d28e7dd..9fbc12a 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -548,7 +548,10 @@ static bool efx_mcdi_complete_async(struct efx_mcdi_iface *mcdi, bool timeout)
 		efx_mcdi_display_error(efx, async->cmd, async->inlen, errbuf,
 				       err_len, rc);
 	}
-	async->complete(efx, async->cookie, rc, outbuf, data_len);
+
+	if (async->complete)
+		async->complete(efx, async->cookie, rc, outbuf,
+				min(async->outlen, data_len));
 	kfree(async);
 
 	efx_mcdi_release(mcdi);
-- 
2.7.4
