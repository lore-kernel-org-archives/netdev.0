From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/2] snap: handle registration error and compile warning
Date: Fri, 20 Feb 2009 18:37:35 -0300
Message-ID: <20090220213735.GC18285@ghostprotocols.net>
References: <20090220100206.533d59d4@extreme> <20090220100302.561dcfab@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38821 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880AbZBTViD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2009 16:38:03 -0500
Content-Disposition: inline
In-Reply-To: <20090220100302.561dcfab@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Feb 20, 2009 at 10:03:02AM -0800, Stephen Hemminger escreveu:
> If this module can't load, it is almost certainly because something else
> is already bound to that SAP. So in that case, return the same error code
> as other SAP usage, and fail the module load.
> 
> Also fixes a compiler warning about printk of non const.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Thanks,


Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
 
> 
> --- a/net/802/psnap.c	2009-02-20 08:38:04.545372306 -0800
> +++ b/net/802/psnap.c	2009-02-20 08:39:16.394961522 -0800
> @@ -95,15 +95,16 @@ static int snap_request(struct datalink_
>  EXPORT_SYMBOL(register_snap_client);
>  EXPORT_SYMBOL(unregister_snap_client);
>  
> -static char snap_err_msg[] __initdata =
> +static const char snap_err_msg[] __initconst =
>  	KERN_CRIT "SNAP - unable to register with 802.2\n";
>  
>  static int __init snap_init(void)
>  {
>  	snap_sap = llc_sap_open(0xAA, snap_rcv);
> -
> -	if (!snap_sap)
> +	if (!snap_sap) {
>  		printk(snap_err_msg);
> +		return -EBUSY;
> +	}
>  
>  	return 0;
>  }
> --
