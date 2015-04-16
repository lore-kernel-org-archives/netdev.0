From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] dsa: mv88e6xxx: Fix error handling in
 mv88e6xxx_set_port_state
Date: Thu, 16 Apr 2015 14:37:42 +0200
Message-ID: <20150416123742.GG13105@lunn.ch>
References: <1429161162-2028-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45664 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752367AbbDPMl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 08:41:59 -0400
Content-Disposition: inline
In-Reply-To: <1429161162-2028-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2015 at 10:12:42PM -0700, Guenter Roeck wrote:
> Return correct error code if _mv88e6xxx_reg_read returns an error.
> 
> Fixes: facd95b2e0ec0 ("net: dsa: mv88e6xxx: Add Hardware bridging support")
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Hi Guenter

Good catch. I'm surprised there is no compiler warning, possibly used
before set.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> ---
>  drivers/net/dsa/mv88e6xxx.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index fc8d3b6ffe8e..f64186a5f634 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -908,8 +908,10 @@ static int mv88e6xxx_set_port_state(struct dsa_switch *ds, int port, u8 state)
>  	mutex_lock(&ps->smi_mutex);
>  
>  	reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_CONTROL);
> -	if (reg < 0)
> +	if (reg < 0) {
> +		ret = reg;
>  		goto abort;
> +	}
>  
>  	oldstate = reg & PORT_CONTROL_STATE_MASK;
>  	if (oldstate != state) {
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
