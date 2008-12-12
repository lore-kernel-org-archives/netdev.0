From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/33] sfc: Board support fixes
Date: Fri, 12 Dec 2008 12:48:26 +0000
Message-ID: <20081212124824.GA10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:47703 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756335AbYLLMs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:48:28 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set dummy monitor method for unrecognised boards.

Clean up board resources if efx_pci_probe_main() fails after board has
been initialised.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index e5024bb..bbc8402 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1743,6 +1743,7 @@ static struct efx_board efx_dummy_board_info = {
 	.init		= efx_port_dummy_op_int,
 	.init_leds	= efx_port_dummy_op_int,
 	.set_fault_led	= efx_port_dummy_op_blink,
+	.monitor	= efx_port_dummy_op_int,
 	.blink		= efx_port_dummy_op_blink,
 	.fini		= efx_port_dummy_op_void,
 };
@@ -1983,6 +1984,7 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	efx_fini_port(efx);
  fail5:
  fail4:
+	efx->board_info.fini(efx);
  fail3:
 	efx_fini_napi(efx);
  fail2:
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
