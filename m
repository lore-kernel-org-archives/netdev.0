From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] net:dsa: check for EPROBE_DEFER from
 dsa_dst_parse()
Date: Wed, 4 Jan 2017 03:19:48 +0100
Message-ID: <20170104021948.GB10768@lunn.ch>
References: <1481129766-10235-1-git-send-email-volodymyr.bendiuga@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        davem@davemloft.net, netdev@vger.kernel.org,
        volodymyr.bendiuga@gmail.com
To: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42572 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752653AbdADCTx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 21:19:53 -0500
Content-Disposition: inline
In-Reply-To: <1481129766-10235-1-git-send-email-volodymyr.bendiuga@westermo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2016 at 05:56:06PM +0100, Volodymyr Bendiuga wrote:
> Since there can be multiple dsa switches stacked together but
> not all of devicetree nodes available at the time of calling
> dsa_dst_parse(), EPROBE_DEFER can be returned by it. When this
> happens, only the last dsa switch has to be deleted by
> dsa_dst_del_ds(), but not the whole list, because next time linux
> cames back to this function it will try to add only the last dsa
> switch which returned EPROBE_DEFER.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
> ---
>  net/dsa/dsa2.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
> index 7924c92..0a5ddaa 100644
> --- a/net/dsa/dsa2.c
> +++ b/net/dsa/dsa2.c
> @@ -673,8 +673,14 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
>  	}
>  
>  	err = dsa_dst_parse(dst);
> -	if (err)
> +	if (err){
> +		if (-EPROBE_DEFER == err) {

Hi Volodymyr

Please can you turn this around, err == -EPROBE_DEFER, to make it
consistent with all the other network code.

With that change

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
