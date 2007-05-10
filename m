From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Fri, 11 May 2007 00:31:04 +1000
Message-ID: <20070510143103.GA27261@gondor.apana.org.au>
References: <1178806376.4074.90.camel@localhost> <OFF6C86B0A.6A40B31A-ON652572D7.004EC8D4-652572D7.004F49D0@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, davem@davemloft.net, netdev@vger.kernel.org,
	Roberto Nibali <ratz@drugphish.ch>, Thomas Graf <tgraf@suug.ch>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3896 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750992AbXEJOb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 10:31:26 -0400
Content-Disposition: inline
In-Reply-To: <OFF6C86B0A.6A40B31A-ON652572D7.004EC8D4-652572D7.004F49D0@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 07:56:02PM +0530, Krishna Kumar2 wrote:
> 
> Herbert,
> 
> -            while (qdisc_restart(dev) < 0 && !netif_queue_stopped(dev))
> -                        /* NOTHING */;
> +            do {
> +                        if (!qdisc_restart(dev))
> +                                    break;
> +            } while (!netif_queue_stopped(dev));
> 
> This could be changed to old format, if required :
> 
> +            while (qdisc_restart(dev)) && !netif_queue_stopped(dev))
> +                 /* NOTHING */;

Actually I deliberately changed it so that it's slightly clearer.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
