From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] bonding: check if clients MAC addr has changed
Date: Tue, 29 Jun 2010 11:39:12 -0400
Message-ID: <4C2A13A0.20200@hp.com>
References: <1277822481-25175-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	Andy Gospodarek <gospo@redhat.com>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:11909 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756571Ab0F2PjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 11:39:15 -0400
In-Reply-To: <1277822481-25175-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2010 10:41 AM, Flavio Leitner wrote:
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 40fdc41..67154bb 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -340,7 +340,8 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
>  
>  	if ((client_info->assigned) &&
>  	    (client_info->ip_src == arp->ip_dst) &&
> -	    (client_info->ip_dst == arp->ip_src)) {
> +	    (client_info->ip_dst == arp->ip_src) &&
> +	    (memcmp(client_info->mac_dst, arp->mac_src, ETH_ALEN))) {
>  		/* update the clients MAC address */
>  		memcpy(client_info->mac_dst, arp->mac_src, ETH_ALEN);
>  		client_info->ntt = 1;

compare_ether_addr_64bits() ?

-Brian
