From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] net: Fix wrong sizeof
Date: Fri, 2 Oct 2009 08:14:11 -0700
Message-ID: <20091002081411.56b263d1.rdunlap@xenotime.net>
References: <20091002113038.1dc3d284@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, stable@kernel.org
To: Jean Delvare <khali@linux-fr.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20091002113038.1dc3d284@hyperion.delvare>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Oct 2009 11:30:38 +0200 Jean Delvare wrote:

> Which is why I have always preferred sizeof(struct foo) over
> sizeof(var).
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>
> Cc: Randy Dunlap <rdunlap@xenotime.net>

Acked-by: Randy Dunlap <rdunlap@xenotime.net>

I also prefer to use sizeof(struct xyz) in my non-kernel code
instead of sizeof(var).

> ---
> Stable team, the non-documentation part of this fix applies to 2.6.31,
> 2.6.30 and 2.6.27.
> 
>  Documentation/networking/timestamping/timestamping.c |    2 +-
>  drivers/net/iseries_veth.c                           |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> --- linux-2.6.32-rc1.orig/Documentation/networking/timestamping/timestamping.c	2009-06-10 05:05:27.000000000 +0200
> +++ linux-2.6.32-rc1/Documentation/networking/timestamping/timestamping.c	2009-10-02 11:07:19.000000000 +0200
> @@ -381,7 +381,7 @@ int main(int argc, char **argv)
>  	memset(&hwtstamp, 0, sizeof(hwtstamp));
>  	strncpy(hwtstamp.ifr_name, interface, sizeof(hwtstamp.ifr_name));
>  	hwtstamp.ifr_data = (void *)&hwconfig;
> -	memset(&hwconfig, 0, sizeof(&hwconfig));
> +	memset(&hwconfig, 0, sizeof(hwconfig));
>  	hwconfig.tx_type =
>  		(so_timestamping_flags & SOF_TIMESTAMPING_TX_HARDWARE) ?
>  		HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
> --- linux-2.6.32-rc1.orig/drivers/net/iseries_veth.c	2009-09-28 10:28:42.000000000 +0200
> +++ linux-2.6.32-rc1/drivers/net/iseries_veth.c	2009-10-02 11:07:15.000000000 +0200
> @@ -495,7 +495,7 @@ static void veth_take_cap_ack(struct vet
>  			   cnx->remote_lp);
>  	} else {
>  		memcpy(&cnx->cap_ack_event, event,
> -		       sizeof(&cnx->cap_ack_event));
> +		       sizeof(cnx->cap_ack_event));
>  		cnx->state |= VETH_STATE_GOTCAPACK;
>  		veth_kick_statemachine(cnx);
>  	}
> 
> 
> -- 
> Jean Delvare
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


---
~Randy
