From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC:  VETH patch to zero timestamp.
Date: Thu, 16 Jul 2009 17:01:43 -0700
Message-ID: <m18wioxjmg.fsf@fess.ebiederm.org>
References: <4A5F9B1D.1050505@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>, xemul@openvz.org,
	Linux Containers <containers@lists.osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38543 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933101AbZGQABu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 20:01:50 -0400
In-Reply-To: <4A5F9B1D.1050505@candelatech.com> (Ben Greear's message of "Thu\, 16 Jul 2009 14\:26\:53 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> The patch below helps when using VETH and bridge(s)
> This makes sure that the pkt timestamp is properly (re)calculated on
> receiving the packet on the peer veth device.
>
> I'm sure this patch is white-space damaged.  If this looks
> useful, I'll generate a clean patch and send as attachment.

We reset everything else that needs to be reset.  So we might as well
reset the timestamps as well.  Unless there is a big performance
impact by doing so.

> Signed-off-by:  Ben Greear<greearb@candelatech.com>
>
>
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 1097c72..e9136af 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -170,7 +173,12 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
>
>         if (skb->len > (rcv->mtu + MTU_PAD))
>                 goto rx_drop;
> -
> +
> +       /* Zero out the time-stamp so that receiving code is forced
> +        * to recalculate it.
> +        */
> +       skb->tstamp.tv64 = 0;
> +
>         skb->pkt_type = PACKET_HOST;
>         skb->protocol = eth_type_trans(skb, rcv);
>         if (dev->features & NETIF_F_NO_CSUM)
>
>
> Thanks,
> Ben
>
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
