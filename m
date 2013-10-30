From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH 2/2] ipv6: Add checks for RAWIP ARP type
Date: Wed, 30 Oct 2013 10:31:38 +0100
Message-ID: <20131030093137.GA3431@omega>
References: <1383124271-15290-1-git-send-email-jukka.rissanen@linux.intel.com>
 <1383124271-15290-3-git-send-email-jukka.rissanen@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:45224 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab3J3Jbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 05:31:45 -0400
Received: by mail-ee0-f52.google.com with SMTP id e49so480744eek.39
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 02:31:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1383124271-15290-3-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jukka,

On Wed, Oct 30, 2013 at 11:11:11AM +0200, Jukka Rissanen wrote:
> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
> ---
>  net/ipv6/addrconf.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index d6ff126..60bf947 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1783,6 +1783,15 @@ static int addrconf_ifid_ip6tnl(u8 *eui, struct net_device *dev)
>  	return 0;
>  }
>  
> +static int addrconf_ifid_rawip(u8 *eui, struct net_device *dev)
> +{
> +	if (dev->addr_len != 8)
> +		return -1;
> +	memcpy(eui, dev->dev_addr, 8);
> +	eui[0] ^= 2;
> +	return 0;
> +}
> +

I think we have already a function like this, look for:

static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)

which is the same for ieee802154 6lowpan. Are there any issues why we
can't use the same function here?

- Alex
