From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/2] dsa: mv88e6171: Fix tagging protocol/Kconfig
Date: Fri, 24 Oct 2014 15:45:13 -0700
Message-ID: <544AD679.9020003@gmail.com>
References: <1414187045-8326-1-git-send-email-andrew@lunn.ch> <1414187045-8326-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49651 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbaJXWph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 18:45:37 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so1907303pab.24
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 15:45:36 -0700 (PDT)
In-Reply-To: <1414187045-8326-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2014 02:44 PM, Andrew Lunn wrote:
> The mv88e6171 can support two different tagging protocols, DSA and
> EDSA. The switch driver structure only allows one protocol to be
> enumerated, and DSA was chosen. However the Kconfig entry ensures the
> EDSA tagging code is built. With a minimal configuration, we then end
> up with a mismatch. The probe is successful, EDSA tagging is used, but
> the switch is configured for DSA, resulting in mangled packets.
> 
> Change the switch driver structure to enumerate EDSA, fixing the
> mismatch.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Fixes: 42f272539487 ("net: DSA: Marvell mv88e6171 switch driver")

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/dsa/mv88e6171.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
> index 1020a7af67cf..78d8e876f3aa 100644
> --- a/drivers/net/dsa/mv88e6171.c
> +++ b/drivers/net/dsa/mv88e6171.c
> @@ -395,7 +395,7 @@ static int mv88e6171_get_sset_count(struct dsa_switch *ds)
>  }
>  
>  struct dsa_switch_driver mv88e6171_switch_driver = {
> -	.tag_protocol		= DSA_TAG_PROTO_DSA,
> +	.tag_protocol		= DSA_TAG_PROTO_EDSA,
>  	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
>  	.probe			= mv88e6171_probe,
>  	.setup			= mv88e6171_setup,
> 
