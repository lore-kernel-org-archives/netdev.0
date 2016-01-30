From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] net: i40e: prevent access to uninitilized variables in
 i40e_tx_enable_csum()
Date: Sat, 30 Jan 2016 19:47:36 +0300
Message-ID: <56ACE928.3080108@virtuozzo.com>
References: <56ACD7C6.1010808@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	intel-wired-lan@lists.osuosl.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26157 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932126AbcA3QsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jan 2016 11:48:07 -0500
In-Reply-To: <56ACD7C6.1010808@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch makes safe an access to 'oiph' and 'oudph' variables
if they was not initilized.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 47bd8b3..779f77e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2363,7 +2363,8 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		}
 		if ((tx_ring->flags & I40E_TXR_FLAGS_OUTER_UDP_CSUM) &&
 		    (l4_tunnel == I40E_TXD_CTX_UDP_TUNNELING)        &&
-		    (*cd_tunneling & I40E_TXD_CTX_QW0_EXT_IP_MASK)) {
+		    (*cd_tunneling & I40E_TXD_CTX_QW0_EXT_IP_MASK)   &&
+		    oudph && oiph) {
 			oudph->check = ~csum_tcpudp_magic(oiph->saddr,
 					oiph->daddr,
 					(skb->len - skb_transport_offset(skb)),
-- 
1.9.1
