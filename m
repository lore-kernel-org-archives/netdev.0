From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] ipv4: flush ARP entries on device change
Date: Wed, 03 Mar 2010 15:06:00 +0100
Message-ID: <4B8E6CC8.3080701@trash.net>
References: <1267624874-22326-1-git-send-email-timo.teras@iki.fi> <1267624874-22326-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40619 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424Ab0CCOGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 09:06:01 -0500
In-Reply-To: <1267624874-22326-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras wrote:
> If device flag IFF_NOARP is changed, we should flush the ARP cache as all
> entries need to get refreshed.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> ---
>  net/ipv4/arp.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index c4dd135..036da92 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -1245,6 +1245,9 @@ static int arp_netdev_event(struct notifier_block *this, unsigned long event, vo
>  		neigh_changeaddr(&arp_tbl, dev);
>  		rt_cache_flush(dev_net(dev), 0);
>  		break;
> +	case NETDEV_CHANGE:
> +		neigh_changeaddr(&arp_tbl, dev);
> +		break;

It would be nice if we could restrict this to IFF_NOARP changes.
