From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbevf: Fix IPv6 GSO type checks
Date: Sat, 23 Jan 2010 02:02:22 -0800
Message-ID: <20100123100140.12032.63705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Sridhar Samudrala <sri@us.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:45748
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752151Ab0AWKCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 05:02:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on patch from Sridhar Samudrala

The following patch fixes the check for IPv6 GSO packet in ixgbevf
driver to use skb_is_gso_v6(). SKB_GSO_DODGY is also set
when packets are forwarded from a guest.

CC: Sridhar Samudrala <sri@us.ibm.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 623353d..7b3af10 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2781,7 +2781,7 @@ static int ixgbevf_tso(struct ixgbevf_adapter *adapter,
 								 IPPROTO_TCP,
 								 0);
 			adapter->hw_tso_ctxt++;
-		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
+		} else if (skb_is_gso_v6(skb)) {
 			ipv6_hdr(skb)->payload_len = 0;
 			tcp_hdr(skb)->check =
 			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,

