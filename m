From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2: hw checksum failures
Date: Mon, 4 Sep 2006 20:34:42 -0700
Message-ID: <20060904203442.1c9ed2eb@localhost.localdomain>
References: <1157416603.22705.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16036 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965128AbWIEDex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 23:34:53 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1157416603.22705.62.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unneeded byte swap was occurring.

--- linux-2.6.orig/drivers/net/sky2.c
+++ linux-2.6/drivers/net/sky2.c
@@ -2001,7 +2001,7 @@ static int sky2_status_intr(struct sky2_
 		case OP_RXCHKS:
 			skb = sky2->rx_ring[sky2->rx_next].skb;
 			skb->ip_summed = CHECKSUM_HW;
-			skb->csum = le16_to_cpu(status);
+			skb->csum = status;
 			break;
 
 		case OP_TXINDEXLE:
