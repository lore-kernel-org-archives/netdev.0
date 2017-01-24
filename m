From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 5/5] gtp: let userspace handle packets for invalid tunnels
Date: Tue, 24 Jan 2017 20:03:49 +0100
Message-ID: <20170124190349.GA9757@salvia>
References: <20170124172402.12096-1-aschultz@tpip.net>
 <20170124172402.12096-6-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60102 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750704AbdAXTEC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 14:04:02 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0FF501EC2C7
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:04:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 00EA0A7BF9
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:04:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 675E0A7DBC
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:03:58 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170124172402.12096-6-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

On Tue, Jan 24, 2017 at 06:24:02PM +0100, Andreas Schultz wrote:
> enable userspace to send error replies for invalid tunnels
> 
> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
> ---
>  drivers/net/gtp.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
> index 912721e..c607333 100644
> --- a/drivers/net/gtp.c
> +++ b/drivers/net/gtp.c
> @@ -198,12 +198,12 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
>  	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
>  	if (!pctx) {
>  		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
> -		return -1;
> +		return 1;
>  	}
>  
>  	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
>  		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
> -		return -1;
> +		return 1;

So userspace gets the packet that we cannot forward. I guess your
userspace codebase performs this sanity checks again so you can send
the appropriate error reply?

>  	}
>  
>  	/* Get rid of the GTP + UDP headers. */
> @@ -247,12 +247,12 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
>  	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
>  	if (!pctx) {
>  		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
> -		return -1;
> +		return 1;
>  	}
>  
>  	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
>  		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
> -		return -1;
> +		return 1;
>  	}
>  
>  	/* Get rid of the GTP + UDP headers. */
> -- 
> 2.10.2
> 
