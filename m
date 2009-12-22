From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [BUG] 2.6.33-rc1 gianfar error message
Date: Tue, 22 Dec 2009 19:27:57 +0100
Message-ID: <20091222182756.GA71759@trillian.comsick.at>
References: <20091220214447.GA10233@trillian.comsick.at>
 <9F4C7D19E8361D4C94921B95BE08B81BA08F3B@zin33exm22.fsl.freescale.net>
 <20091221072704.GA12110@gibson.comsick.at>
 <9F4C7D19E8361D4C94921B95BE08B81BA08F83@zin33exm22.fsl.freescale.net>
 <20091221163843.GB3529@gibson.comsick.at>
 <9F4C7D19E8361D4C94921B95BE08B81BA08FCA@zin33exm22.fsl.freescale.net>
 <20091222181000.GA71727@trillian.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:57697
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751475AbZLVS2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 13:28:04 -0500
Content-Disposition: inline
In-Reply-To: <20091222181000.GA71727@trillian.comsick.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2009.12.22 19:10:00 , Michael Guntsche wrote:
> Since you said that the first patch is not needed
> 
> @@ -2470,10 +2470,11 @@ static int gfar_process_frame(struct net_device
>         fcb = (struct rxfcb *)skb->data;
> 
>         /* Remove the FCB from the skb */
> -       skb_set_queue_mapping(skb, fcb->rq);
>         /* Remove the padded bytes, if there are any */
> -       if (amount_pull)
> +       if (amount_pull) {
> +               skb_set_queue_mapping(skb, fcb->rq);
>                 skb_pull(skb, amount_pull);
> +       }
> 
>         if (priv->rx_csum_enable)
>                 gfar_rx_checksum(skb, fcb);
> 
> I only applied the second one and tested again. Right after the reboot
> I got an error so apparently this change IS required as well. 

I tested this now in the opposite direction and apparently ONLY this
patch is needed. I commented out the second diff and did not get any
errors so far. Sorry for not testing this before sending my previous
mail.

Kind regards,
Michael
