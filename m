From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT 1/3] 8139: safer spin loop for get_statistics
Date: Thu, 17 Mar 2005 00:21:52 +0100
Message-ID: <20050316232152.GA27664@electric-eye.fr.zoreil.com>
References: <20050316150429.375845f1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050316150429.375845f1@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
> --- a/drivers/net/8139cp.c	2005-03-16 14:54:48 -08:00
> +++ b/drivers/net/8139cp.c	2005-03-16 14:54:48 -08:00
[...]
> -	while (work-- > 0) {
> +	for (i = 0; i < 1000; i++) {
>  		if ((cpr32(StatsAddr) & DumpStats) == 0)
>  			break;
> -		cpu_relax();
> +		udelay(10);
>  	}

I am tempted to remove some stuff:

	while (cpr32(StatsAddr) & DumpStats) {
		if (msleep_interruptible(1))
			break;
	}

May be we could remove "cpr32(StatsAddr);" too as any posted write will
be commited in the loop anyway.

--
Ueimor
