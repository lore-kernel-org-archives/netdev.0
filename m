From: Vicente Feito <vicente.feito@gmail.com>
Subject: [PATCH 2.6.12-rc1-mm1] net/ethernet/eth.c - eth_header
Date: Wed, 23 Mar 2005 17:34:58 +0000
Message-ID: <200503231734.59277.vicente.feito@gmail.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_DjaQCQ2KX9Rm9+v"
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_DjaQCQ2KX9Rm9+v
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
Please consider applying (or droping).
Thank you.

Description: This patch prevent drivers from calling eth_header with a 802.3
frame using a len>1536. In such a case returns -EINVAL, which was hard to
choose because the ETH_HLEN is supposed to return.

Signed-off-by: Vicente Feito <vicente.feito@gmail.com>

--Boundary-00=_DjaQCQ2KX9Rm9+v
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="eth.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="eth.patch"

--- linux-2.6.12-rc1-mm1/net/ethernet/eth.c.orig	2005-03-22 12:49:08.000000000 +0000
+++ linux-2.6.12-rc1-mm1/net/ethernet/eth.c	2005-03-22 12:49:36.000000000 +0000
@@ -78,6 +78,8 @@ int eth_header(struct sk_buff *skb, stru
 {
 	struct ethhdr *eth = (struct ethhdr *)skb_push(skb,ETH_HLEN);
 
+	if (type == ETH_P_802_3 && len >= 1536)
+		return -EINVAL;
 	/* 
 	 *	Set the protocol type. For a packet of type ETH_P_802_3 we put the length
 	 *	in here instead. It is up to the 802.2 layer to carry protocol information.

--Boundary-00=_DjaQCQ2KX9Rm9+v--
