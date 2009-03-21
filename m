From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 32/77] usbnet: convert rndis driver to use dev_get_stats
Date: Sat, 21 Mar 2009 02:22:05 -0700
Message-ID: <200903210222.06107.david-b@pacbell.net>
References: <20090321053527.316395697@vyatta.com> <20090321053714.963078292@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp127.sbc.mail.sp1.yahoo.com ([69.147.65.186]:46448 "HELO
	smtp127.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754227AbZCUJZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 05:25:58 -0400
In-Reply-To: <20090321053714.963078292@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 March 2009, Stephen Hemminger wrote:
> dev_get_stats() handles all issues with net_device_ops
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>


> ---
>  drivers/usb/gadget/rndis.c |    7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> --- a/drivers/usb/gadget/rndis.c	2009-03-20 12:18:22.054027493 -0700
> +++ b/drivers/usb/gadget/rndis.c	2009-03-20 12:18:28.620714647 -0700
> @@ -170,7 +170,7 @@ gen_ndis_query_resp (int configNr, u32 O
>  	int			i, count;
>  	rndis_query_cmplt_type	*resp;
>  	struct net_device	*net;
> -	struct net_device_stats	*stats;
> +	const struct net_device_stats	*stats;
>  
>  	if (!r) return -ENOMEM;
>  	resp = (rndis_query_cmplt_type *) r->buf;
> @@ -193,10 +193,7 @@ gen_ndis_query_resp (int configNr, u32 O
>  	resp->InformationBufferOffset = cpu_to_le32 (16);
>  
>  	net = rndis_per_dev_params[configNr].dev;
> -	if (net->get_stats)
> -		stats = net->get_stats(net);
> -	else
> -		stats = NULL;
> +	stats = dev_get_stats(net);
>  
>  	switch (OID) {
>  
> 
> -- 
> 
> 


