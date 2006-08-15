From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC][NET::SCHED]: cleanup qdisc_restart
Date: Tue, 15 Aug 2006 07:42:39 -0700
Message-ID: <44E1DD5F.4020603@osdl.org>
References: <1155408186.5091.46.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27083 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932344AbWHNOoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 10:44:00 -0400
To: hadi@cyberus.ca
In-Reply-To: <1155408186.5091.46.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Folks,
>
> I am not a big readability officianado, but this piece of code has
> become a victim of hairy activities over the last few years. So while i
> was furiously chasing Herbert's qdisc_is_running changes[1] i made a
> small cleanup just so that i could absorb what was going on.
>
> The patch included is a small side effect of that effort (theres a lot
> of WIP as well which is not part of this patch that may never see the
> light of day).
>
> Actually the patch itself may be slightly unreadable, so i have attached
> how qdisc_restart looks after the patch.
>
> I am not yet asking for inclusion, but if people are fine with it i will
> run some performance tests to make sure we at least get the same numbers
> as before and submit for 2.6.19. I have tested the code with a lot of
> other stuff but not its the version i am attaching. It does compile
> however ;->
>
> Also if i am missing some piece of the translation please comment.
> Alexey, I know you havent looked at this creation of yours in years and
> a few changes have happened since, so please if you have time stare and
> comment.
>
> cheers,
> jamal
>
> [1] I wanted to check the qdisc is running change before 2.6.18 came
> out. I have to say I have failed to find any issues with it. There are
> some theoretical issues but i cant practically create them. Maybe we can
> chat over a drink.
>   
> ------------------------------------------------------------------------
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 75f02d8..49278c8 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -75,8 +75,11 @@ #define MAX_ADDR_LEN	32		/* Largest hard
>  
>  /* Driver transmit return codes */
>  #define NETDEV_TX_OK 0		/* driver took care of packet */
> -#define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
> -#define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
> +#define NETDEV_TX_BUSY -1	/* driver tx path was busy*/
> +#define NETDEV_TX_LOCKED -2	/* driver tx lock was already taken */
> +#define NETDEV_TX_DROP -3      /* request caller to drop packet */
> +#define NETDEV_TX_QUEUE -4     /* request caller to requeue packet */
>   

Please don't change the values because some older drvers still return 1 
rather
than NETDEV_TX_BUSY
