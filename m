From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 19:52:32 +0200
Message-ID: <466D8BE0.5040708@trash.net>
References: <20070604214037.1524.58506.stgit@localhost.localdomain> <20070604214045.1524.18254.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48208 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbXFKRzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 13:55:06 -0400
In-Reply-To: <20070604214045.1524.18254.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index e7367c7..8bcd870 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -215,6 +215,7 @@ typedef unsigned char *sk_buff_data_t;
>   *	@pkt_type: Packet class
>   *	@fclone: skbuff clone status
>   *	@ip_summed: Driver fed us an IP checksum
> + *	@queue_mapping: Queue mapping for multiqueue devices
>   *	@priority: Packet queueing priority
>   *	@users: User count - see {datagram,tcp}.c
>   *	@protocol: Packet protocol from driver
> @@ -269,6 +270,7 @@ struct sk_buff {
>  			__u16	csum_offset;
>  		};
>  	};
> +	__u16			queue_mapping;
>  	__u32			priority;
>  	__u8			local_df:1,
>  				cloned:1,


I think we can reuse skb->priority. Assuming only real hardware
devices use multiqueue support, there should be no user of
skb->priority after egress qdisc classification. The only reason
to preserve it in the qdisc layer is for software devices.

Grepping through drivers/net shows a few users, bot most seem
to be using it on the RX path and some use it to store internal
data.

