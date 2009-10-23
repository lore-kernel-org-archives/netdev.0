From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] Modify bonding hash transmit policies to use the packet's source MAC address
Date: Fri, 23 Oct 2009 09:23:12 -0700
Message-ID: <15644.1256314992@death.nxdomain.ibm.com>
References: <4AE1A37F.8010203@gmail.com> <20091023140845.GA24564@spaans.fox.local>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jasper Spaans <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:35539 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbZJWSNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:13:25 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9NI6jpu021328
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 12:06:45 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n9NIDP7f204410
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 12:13:25 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9NIDO0i016490
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 12:13:25 -0600
In-reply-to: <20091023140845.GA24564@spaans.fox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jasper Spaans <spaans@fox-it.com> wrote:

>Modify bonding hash transmit policies to use the psource MAC address of
>the packet instead of the MAC address configured for the bonding device.
>
>The old sitation conflicts with the documentation.
>
>Signed-off-by: Jasper Spaans <spaans@fox-it.com>

	Looks good.

	Dave, please apply.  This may be suitable for -stable, as it's
pretty much a day one bug.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>---
> drivers/net/bonding/bond_main.c |    8 ++++----
> 1 files changed, 4 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 69c5b15..3f05267 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3665,10 +3665,10 @@ static int bond_xmit_hash_policy_l23(struct sk_buff *skb,
>
> 	if (skb->protocol == htons(ETH_P_IP)) {
> 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
>-			(data->h_dest[5] ^ bond_dev->dev_addr[5])) % count;
>+			(data->h_dest[5] ^ data->h_source[5])) % count;
> 	}
>
>-	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
>+	return (data->h_dest[5] ^ data->h_source[5]) % count;
> }
>
> /*
>@@ -3695,7 +3695,7 @@ static int bond_xmit_hash_policy_l34(struct sk_buff *skb,
>
> 	}
>
>-	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
>+	return (data->h_dest[5] ^ data->h_source[5]) % count;
> }
>
> /*
>@@ -3706,7 +3706,7 @@ static int bond_xmit_hash_policy_l2(struct sk_buff *skb,
> {
> 	struct ethhdr *data = (struct ethhdr *)skb->data;
>
>-	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
>+	return (data->h_dest[5] ^ data->h_source[5]) % count;
> }
>
> /*-------------------------- Device entry points ----------------------------*/
>-- 
>1.6.0.4
>
>
>-- 
>Fox-IT Experts in IT Security!
>T: +31 (0) 15 284 79 99
>KvK Haaglanden 27301624
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
