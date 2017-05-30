From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 3/6] net: dsa: remove dsa_uses_tagged_protocol
Date: Tue, 30 May 2017 13:47:53 -0700
Message-ID: <3741e6b9-98a5-c587-ef8f-851b17cb3145@gmail.com>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
 <20170530183319.10718-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33160 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbdE3Ur4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:47:56 -0400
In-Reply-To: <20170530183319.10718-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2017 11:33 AM, Vivien Didelot wrote:
> Since dev->dsa_ptr is a pointer to a dsa_switch_tree, there is no need
> to have another inline helper just to check rcv.
> 
> Remove dsa_uses_tagged_protocol and check dsa_ptr && dsa_ptr->rcv
> together at the same time.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

FYI, the part that matters here is that we know whether the master
network device actually uses a tagged DSA protocol, this is important
for e.g: bridge (see 8db0a2ee2c6302a1dcbcdb93cb731dfc6c0cdb5e). Some
drivers like bcmsysport.c also care about that in order to enable
specific switch tagging protocol parsing hints.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  include/net/dsa.h | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 58297e4c6b31..4675b52c964c 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -467,16 +467,10 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
>  struct net_device *dsa_dev_to_net_device(struct device *dev);
>  
>  /* Keep inline for faster access in hot path */
> -static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
> -{
> -	return dst->rcv != NULL;
> -}
> -
>  static inline bool netdev_uses_dsa(struct net_device *dev)
>  {
>  #if IS_ENABLED(CONFIG_NET_DSA)
> -	if (dev->dsa_ptr != NULL)
> -		return dsa_uses_tagged_protocol(dev->dsa_ptr);
> +	return dev->dsa_ptr && dev->dsa_ptr->rcv;
>  #endif
>  	return false;
>  }
> 


-- 
Florian
