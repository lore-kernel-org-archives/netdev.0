From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: add CONFIG_NET_DSA_LEGACY
Date: Tue, 11 Apr 2017 23:20:26 +0200
Message-ID: <20170411212026.GA7023@lunn.ch>
References: <20170411205237.29309-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55844 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751608AbdDKVUb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 17:20:31 -0400
Content-Disposition: inline
In-Reply-To: <20170411205237.29309-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#ifdef CONFIG_NET_DSA_LEGACY
>  static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
>  				       struct device *host_dev, int sw_addr,
>  				       void **priv)
> @@ -4256,6 +4257,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
>  
>  	return NULL;
>  }
> +#endif /* CONFIG_NET_DSA_LEGACY */

Hi Vivien

Rather than scatter #ifdef everywhere, can you use

       if (!IS_ENABLED(CONFIG_NET_DSA_LEGACY))
              return NULL

The compiler will then throw away the rest of the function, after
checking it does actually compile.

	 Andrew
