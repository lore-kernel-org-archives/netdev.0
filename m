From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] dsa: fix promiscuity leak on slave dev open error
Date: Fri, 26 Jun 2015 17:04:01 +0200
Message-ID: <20150626150401.GH9469@lunn.ch>
References: <1435240213-15179-1-git-send-email-giladb@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Gilad Ben-Yossef <gilad@benyossef.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Scott Feldman <sfeldma@gmail.com>
To: giladb@ezchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58383 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000AbbFZPKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 11:10:03 -0400
Content-Disposition: inline
In-Reply-To: <1435240213-15179-1-git-send-email-giladb@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2015 at 04:50:13PM +0300, giladb@ezchip.com wrote:
> From: Gilad Ben-Yossef <gilad@benyossef.com>
> 
> DSA master netdev promiscuity counter was not being properly
> decremented on slave device open error path.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> CC: Gilad Ben-Yossef <giladb@ezchip.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Florian Fainelli <f.fainelli@gmail.com>
> CC: Guenter Roeck <linux@roeck-us.net>
> CC: Andrew Lunn <andrew@lunn.ch>
> CC: Scott Feldman <sfeldma@gmail.com>

Hi Gilad

Acked-by: Andrew Lunn <andrew@lunn.ch>

FYI: I grep'ed the whole kernel. This seems to be the only place 0 is
passed to dev_set_promiscuity(), i.e. the same bug is not present
anywhere else.

Thanks
	Andrew

> ---
>  net/dsa/slave.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 04ffad3..0917123 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -112,7 +112,7 @@ static int dsa_slave_open(struct net_device *dev)
>  
>  clear_promisc:
>  	if (dev->flags & IFF_PROMISC)
> -		dev_set_promiscuity(master, 0);
> +		dev_set_promiscuity(master, -1);
>  clear_allmulti:
>  	if (dev->flags & IFF_ALLMULTI)
>  		dev_set_allmulti(master, -1);
> -- 
> 1.7.1
> 
