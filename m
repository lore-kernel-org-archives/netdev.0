From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/6] sfc: Fix null function pointer in
 efx_sriov_channel_type
Date: Tue, 2 Oct 2012 02:27:15 +0100
Message-ID: <1349141235.2577.74.camel@bwh-desktop.uk.solarflarecom.com>
References: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17159 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752282Ab2JBB1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 21:27:18 -0400
In-Reply-To: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c31e5f9 ('sfc: Add channel specific receive_skb handler and
post_remove callback') added the function pointer field
efx_channel_type::post_remove and an unconditional call through it.

This field should have been initialised to efx_channel_dummy_op_void
in the existing instances of efx_channel_type, but this was only done
in efx_default_channel_type.  Consequently, if a device has SR-IOV
enabled then removing the driver or device will result in an oops.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/siena_sriov.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index a8f48a4..d49b53d 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -1035,6 +1035,7 @@ efx_sriov_get_channel_name(struct efx_channel *channel, char *buf, size_t len)
 static const struct efx_channel_type efx_sriov_channel_type = {
 	.handle_no_channel	= efx_sriov_handle_no_channel,
 	.pre_probe		= efx_sriov_probe_channel,
+	.post_remove		= efx_channel_dummy_op_void,
 	.get_name		= efx_sriov_get_channel_name,
 	/* no copy operation; channel must not be reallocated */
 	.keep_eventq		= true,
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
