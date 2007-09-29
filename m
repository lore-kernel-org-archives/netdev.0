From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 08/17] sky2: avoid divide in receive path
Date: Sat, 29 Sep 2007 01:51:16 -0400
Message-ID: <46FDE7D4.9050909@garzik.org>
References: <200709290542.l8T5gAHW002284@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: akpm@linux-foundation.org, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47449 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607AbXI2FvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 01:51:20 -0400
In-Reply-To: <200709290542.l8T5gAHW002284@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Avoid divide (modulus) in receive buffer handling path.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/sky2.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff -puN drivers/net/sky2.c~sky2-avoid-divide-in-receive-path drivers/net/sky2.c
> --- a/drivers/net/sky2.c~sky2-avoid-divide-in-receive-path
> +++ a/drivers/net/sky2.c
> @@ -2155,7 +2155,8 @@ static struct sk_buff *sky2_receive(stru
>  		printk(KERN_DEBUG PFX "%s: rx slot %u status 0x%x len %d\n",
>  		       dev->name, sky2->rx_next, status, length);
>  
> -	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
> +	if (++sky2->rx_next >= sky2->rx_pending)
> +		sky2->rx_next = 0;


it is silly to introduce a branch just for this.

require that the ring size is a power-of-2, and then replace the divide 
with a mask.

