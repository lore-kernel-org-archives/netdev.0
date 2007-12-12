From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPIP: Allow rebinding the tunnel to another interface
Date: Wed, 12 Dec 2007 17:00:14 +0100
Message-ID: <4760058E.5080403@trash.net>
References: <20071212163451.498b5726@brian.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcela Maslanova <mmaslano@redhat.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49135 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758489AbXLLQAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 11:00:24 -0500
In-Reply-To: <20071212163451.498b5726@brian.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Schmidt wrote:
> +static void ipip_tunnel_bind_dev(struct net_device *dev)
> +{
...
> +	dev->iflink = tunnel->parms.link;
> +}
> +
>  static int
>  ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
>  {
> @@ -723,6 +757,10 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
>  				t->parms.iph.ttl = p.iph.ttl;
>  				t->parms.iph.tos = p.iph.tos;
>  				t->parms.iph.frag_off = p.iph.frag_off;
> +				if (t->parms.link != p.link) {
> +					t->parms.link = p.link;
> +					ipip_tunnel_bind_dev(dev);
> +				}

If you change dev->iflink this should trigger a rtnetlink
notification.
