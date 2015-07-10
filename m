From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next 5/9] be2net: convert dest field in udp-hdr to host-endian
Date: Fri, 10 Jul 2015 05:32:47 -0400
Message-ID: <1436520771-11656-6-git-send-email-sathya.perla@avagotech.com>
References: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56757 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753416AbbGJJ0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 05:26:34 -0400
In-Reply-To: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>

The "dest" field in the UDP-hdr of a TX skb is in network endian format.
Convert it to host endian before accessing it. The os2bmc patch,
mentioned below introduced this code.

Fixes: 760c295e0e8d ("be2net: Support for OS2BMC")
Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 8ef7ea5..c996dd7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1254,7 +1254,7 @@ static bool be_send_pkt_to_bmc(struct be_adapter *adapter,
 	if (is_udp_pkt((*skb))) {
 		struct udphdr *udp = udp_hdr((*skb));
 
-		switch (udp->dest) {
+		switch (ntohs(udp->dest)) {
 		case DHCP_CLIENT_PORT:
 			os2bmc = is_dhcp_client_filt_enabled(adapter);
 			goto done;
-- 
2.4.1
