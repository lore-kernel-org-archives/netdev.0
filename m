From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 4/6] 6lowpan: add udp warning for elided
 checksum
Date: Thu, 14 Nov 2013 08:32:01 -0800
Message-ID: <1384446721.15774.5.camel@joe-AO722>
References: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
	 <1384444132-1427-5-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	jukka.rissanen@linux.intel.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0219.hostedemail.com ([216.40.44.219]:37395 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754534Ab3KNQcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 11:32:05 -0500
In-Reply-To: <1384444132-1427-5-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 16:48 +0100, Alexander Aring wrote:
> Bit 5 of "UDP LOWPAN_NHC Format" indicate that the checksum can be elided.
> The host need to calculate the udp checksum afterwards but this isn't
> supported right now.
[]
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
[]
> @@ -448,9 +448,14 @@ lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
>  		pr_debug("uncompressed UDP ports: src = %d, dst = %d\n",
>  			 ntohs(uh->source), ntohs(uh->dest));
>  
> -		/* copy checksum */
> -		memcpy(&uh->check, &skb->data[0], 2);
> -		skb_pull(skb, 2);
> +		/* checksum */
> +		if (tmp & LOWPAN_NHC_UDP_CS_C) {
> +			pr_debug("checksum elided currently not supported");

This looks like it could need ratelimiting
Also, it should end in "\n".  Maybe use:

	pr_debug_ratelimited("checksum elided currently not supported\n");
