From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.7-rc3-mm2 2/5] via-velocity: uniformize use of OWNED_BY_NIC
Date: Fri, 18 Jun 2004 17:02:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D3584A.9010009@pobox.com>
References: <20040618221014.A15640@electric-eye.fr.zoreil.com> <20040618221142.A20210@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, alan@redhat.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040618221142.A20210@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Introduce velocity_give_rx_desc() to uniformize the use of OWNED_BY_NIC
> through the driver.
> 
> diff -puN drivers/net/via-velocity.c~via-velocity-30 drivers/net/via-velocity.c
> --- linux-2.6.7-rc3/drivers/net/via-velocity.c~via-velocity-30	2004-06-18 21:34:14.000000000 +0200
> +++ linux-2.6.7-rc3-fr/drivers/net/via-velocity.c	2004-06-18 21:34:14.000000000 +0200
> @@ -465,6 +465,12 @@ static void velocity_init_cam_filter(str
>  	}
>  }
>  
> +static inline void velocity_give_rx_desc(struct rx_desc *rd)
> +{
> +	*(u32 *)&rd->rdesc0 = 0;
> +	rd->rdesc0.owner = cpu_to_le32(OWNED_BY_NIC);
> +}

The patch itself is OK, and I will merge, but I wonder:

isn't a wmb() needed perhaps?

	Jeff
