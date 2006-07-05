From: John Heffner <jheffner@psc.edu>
Subject: Re: [TCP] window reduction fix
Date: Wed, 05 Jul 2006 15:17:23 -0400
Message-ID: <44AC1043.10603@psc.edu>
References: <8dd26e70607050924q48954801h8fd4c32efa37929@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, vacirca@infocom.uniroma1.it,
	Andrea Baiocchi <andrea.baiocchi@uniroma1.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:48112 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S964993AbWGETRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 15:17:36 -0400
To: "Angelo P. Castellani" <angelo.castellani@gmail.com>
In-Reply-To: <8dd26e70607050924q48954801h8fd4c32efa37929@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hm, wouldn't that violate the TCP spec?

   -John


Angelo P. Castellani wrote:
> I forward the message because it seems hasn't get through to mailing
> list (removing references to a word that seems blocking the message).
> 
> The previous message "[TCP] window update during recovery (continuing
> on window reduction)" references this one
> 
> Regards,
> Angelo P. Castellani
> ---------- Forwarded message ----------
> From: Angelo P. Castellani <angelo.castellani+lkml@gmail.com>
> Date: 5-lug-2006 16.22
> Subject: [TCP] window reduction fix
> To: netdev <netdev@vger.kernel.org>
> Cc: Francesco Vacirca <francesco@net.infocom.uniroma1.it>, Andrea
> Baiocchi <andrea.baiocchi@uniroma1.it>
> 
> 
> When the receiver buffer is filling up, it should reduce the allowed
> receive window value piggybacked in the acks, according to the free
> space actually left in the buffer.
> 
> So it should send in the tcp acks returning to the sender a window
> field with a value not higher than the space available to store
> incoming segments.
> 
> The attached patch addresses this issue, requests to the sender a
> window size not bigger than the free space for incoming data.
> 
> Regards,
> Angelo P. Castellani
> 
> 
> ------------------------------------------------------------------------
> 
> diff -urd linux-2.6.16-orig/net/ipv4/tcp_output.c linux-2.6.16-winreduction/net/ipv4/tcp_output.c
> --- linux-2.6.16-orig/net/ipv4/tcp_output.c	2006-05-16 14:53:02.000000000 +0200
> +++ linux-2.6.16-winreduction/net/ipv4/tcp_output.c	2006-07-05 16:35:55.000000000 +0200
> @@ -218,18 +218,15 @@
>  	u32 cur_win = tcp_receive_window(tp);
>  	u32 new_win = __tcp_select_window(sk);
>  
> -	/* Never shrink the offered window */
> -	if(new_win < cur_win) {
> -		/* Danger Will Robinson!
> -		 * Don't update rcv_wup/rcv_wnd here or else
> -		 * we will not be able to advertise a zero
> -		 * window in time.  --DaveM
> -		 *
> -		 * Relax Will Robinson.
> -		 */
> -		new_win = cur_win;
> -	}
> -	tp->rcv_wnd = new_win;
> +	/* Danger Will Robinson!
> +	 * Don't update rcv_wup/rcv_wnd here or else
> +	 * we will not be able to advertise a zero
> +	 * window in time.  --DaveM
> +	 *
> +	 * Relax Will Robinson.
> +	 */
> +	// Anyway let's send the right window reduction to the sender.
> +	tp->rcv_wnd = max( new_win, cur_win );
>  	tp->rcv_wup = tp->rcv_nxt;
>  
>  	/* Make sure we do not exceed the maximum possible
> 
> 
> 
> 

