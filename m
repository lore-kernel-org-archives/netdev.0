From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH net-next] cxgb4: Do not set net_device::dev_id to VI
 index
Date: Mon, 10 Jun 2013 17:34:13 +0100
Message-ID: <1370882053.1933.13.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, <Narendra_K@Dell.com>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24671 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab3FJQeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 12:34:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_device::dev_id should not be used merely to indicate a VI index,
as it affects the way the local part of IPv6 addresses is normally
generated.

This field was intended for use where multiple devices may share a
single assigned MAC address and need to have different IPv6 addresses.
T4 VIs each have their own MAC address.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Dimitris, I don't know whether my last statement ('VIs each have their
own MAC address') is actually correct.  If not then the driver is quite
right to set dev_id.

Ben.

 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index bff89a4..4cbb2f9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3782,7 +3782,6 @@ int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 		p->lport = j;
 		p->rss_size = rss_size;
 		memcpy(adap->port[i]->dev_addr, addr, ETH_ALEN);
-		adap->port[i]->dev_id = j;
 
 		ret = ntohl(c.u.info.lstatus_to_modtype);
 		p->mdio_addr = (ret & FW_PORT_CMD_MDIOCAP) ?

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
