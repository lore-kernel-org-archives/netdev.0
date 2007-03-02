From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [RFC] Arp announce (for Xen)
Date: Fri, 2 Mar 2007 10:09:13 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703021006470.27021@netcore.fi>
References: <20070301232443.195603797@goop.org> <20070301232529.648076372@goop.org>
 <20070301164214.4a40bc59@freekitty> <45E7764A.7000100@goop.org>
 <20070301173030.754514ec@freekitty>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:56395 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422748AbXCBJNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 04:13:19 -0500
In-Reply-To: <20070301173030.754514ec@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Mar 2007, Stephen Hemminger wrote:
> What about implementing the unused arp_announce flag on the inetdevice?
> Something like the following.  Totally untested...
>
> Looks like it either was there (and got removed) or was planned but
> never implemented.

If something like this goes in, it wouldn't hurt to do similar with 
IPv6 (RFC2461 section 7.2.6).

There are very popular hardware-based routers which refresh their NDP 
caches only every 24 hours or 20 minutes (depending on the software 
version).  Sending unsolicited NAs would eliminate traffic 
blackholing.

> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index e10794d..cefc339 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1089,6 +1089,16 @@ static int inetdev_event(struct notifier
> 			}
> 		}
> 		ip_mc_up(in_dev);
> +		/* fallthru */
> +
> +	case NETDEV_CHANGEADDR:
> +		/* Send gratuitous ARP in case of address change or new device */
> +		if (IN_DEV_ARP_ANNOUNCE(in_dev))
> +			arp_send(ARPOP_REQUEST, ETH_P_ARP,
> +				 in_dev->ifa_list->ifa_address, dev,
> +				 in_dev->ifa_list->ifa_address, NULL,
> +				 dev->dev_addr, NULL);
> +
> 		break;
> 	case NETDEV_DOWN:
> 		ip_mc_down(in_dev);
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
