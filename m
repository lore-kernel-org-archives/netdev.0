From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ipv6 addrconf: Fix addrconf_ifid_eui64 of 802.15.4
 devices
Date: Thu, 7 Mar 2013 22:41:28 +0000
Message-ID: <1362696088.2936.47.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362687183-3425-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>,
	<linux-zigbee-devel@lists.sourceforge.net>,
	<netdev@vger.kernel.org>
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46437 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061Ab3CGWlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 17:41:50 -0500
In-Reply-To: <1362687183-3425-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-07 at 21:13 +0100, Alexander Aring wrote:
> The function addrconf_ifid_eui64 will copy eui into dev->dev_addr.
> We need first to manipulate eui[0] before we call memcpy afterwards.

memcpy() does not work that way.

> Broken since commit:
> 5e98a36ed4bf6ea396170e3af0dd4fcbe51d772f
> 
> Since this commit I got many trouble with the ieee802154 stack.

Your change is effectively reverting that commit.

Ben.

> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>  net/ipv6/addrconf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index fa36a67..4460237 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1731,8 +1731,8 @@ static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
>  {
>  	if (dev->addr_len != IEEE802154_ADDR_LEN)
>  		return -1;
> -	memcpy(eui, dev->dev_addr, 8);
>  	eui[0] ^= 2;
> +	memcpy(eui, dev->dev_addr, 8);
>  	return 0;
>  }
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
