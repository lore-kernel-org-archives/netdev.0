From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Fix warning with
 CONFIG_OF=n
Date: Thu, 6 Apr 2017 16:04:31 +0200
Message-ID: <20170406140431.GA17713@lunn.ch>
References: <20170406134736.24329-1-f.fainelli@gmail.com>
 <20170406134736.24329-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47760 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935129AbdDFOEf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 10:04:35 -0400
Content-Disposition: inline
In-Reply-To: <20170406134736.24329-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 06, 2017 at 06:47:35AM -0700, Florian Fainelli wrote:
> When CONFIG_OF=n, we will see the following warning:
> 
> drivers/net/dsa/mv88e6xxx/chip.c:2834:34: warning: 'mv88e6xxx_mdio_external_match' defined but not used [-Wunused-const-variable=]
>  static const struct of_device_id mv88e6xxx_mdio_external_match[] = {
>                                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 44ba8cff5631..64cbc4c04907 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -2831,11 +2831,13 @@ static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
>  	return 0;
>  }
>  
> +#ifdef CONFIG_OF
>  static const struct of_device_id mv88e6xxx_mdio_external_match[] = {
>  	{ .compatible = "marvell,mv88e6xxx-mdio-external",
>  	  .data = (void *)true },
>  	{ },
>  };
> +#endif

Hi Florian

Maybe a better fix is to make the stub of of_match_node() an inline
function, so its parameters are used. That will fix this warning
everywhere in the kernel, not just in this driver.

	   Andrew
