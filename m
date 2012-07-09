From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] net/ipv4/ipip: add support to move between network
 namespaces
Date: Mon, 09 Jul 2012 09:00:54 -0700
Message-ID: <1341849654.6118.5.camel@joe2Laptop>
References: <1341848473-2666-1-git-send-email-christian.franke@adytonsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christian Franke <christian.franke@adytonsystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42441 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752065Ab2GIQAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2012 12:00:55 -0400
In-Reply-To: <1341848473-2666-1-git-send-email-christian.franke@adytonsystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-09 at 17:41 +0200, Christian Franke wrote:
> Below there is a first attempt at adding support for IPIP tunnels to be moved
> across network namespaces. This allows e.g. for tunnel setups where the inner
> network is completely isolated from the outer transport network.

trivia:

> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
[]
> @@ -652,6 +660,9 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
>  		break;
>  
>  	case SIOCADDTUNNEL:
> +		/* New Tunnels will be created in the current namespace */

New tunnels

> @@ -701,6 +712,15 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
>  				t->parms.iph.tos = p.iph.tos;
>  				t->parms.iph.frag_off = p.iph.frag_off;
>  				if (t->parms.link != p.link) {
> +					if (!net_eq(dev_net(dev),
> +						    target_net(dev))) {
> +						pr_info_once("%s: rebinding "
> +							     "cross ns device "
> +							     "is not supported\n",
> +							     __func__);

Please coalesce format strings.
						pr_info_once("%s: rebinding cross ns device is not supported\n",
							     __func__);

shouldn't "cross ns device" be "different ns devices"?
