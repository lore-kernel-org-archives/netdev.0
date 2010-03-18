From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 6/9] ipv6: addrconf timer changes
Date: Thu, 18 Mar 2010 16:37:43 +0900
Message-ID: <1268897863.10592.38.camel@cirrhata.linux-ipv6.org>
References: <20100318063108.109693694@vyatta.com>
	 <20100318063123.232844056@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:49397 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753191Ab0CRHke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 03:40:34 -0400
In-Reply-To: <20100318063123.232844056@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Stephen Hemminger wrote:

> For addrconf timer use round_jiffies to round off to next interval
> (rather than manual rounding).
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> ---
>  net/ipv6/addrconf.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/net/ipv6/addrconf.c	2010-03-15 16:10:25.069213714 -0700
> +++ b/net/ipv6/addrconf.c	2010-03-15 16:10:25.709836446 -0700
> @@ -3194,7 +3194,7 @@ restart:
>  		}
>  	}
>  
> -	addr_chk_timer.expires = time_before(next, jiffies + HZ) ? jiffies + HZ : next;
> +	addr_chk_timer.expires = round_jiffies(next);
>  	add_timer(&addr_chk_timer);
>  	spin_unlock(&addrconf_verify_lock);
>  	rcu_read_unlock_bh();
> 

I'd like to NAK this.

This could round down, but in this routine, the time
is checked.  If the time is not yet, no process and reschedule
happens again.  So, I don't think it is useful.

Well,
   addr_chk_timer.expires = next + HZ;
or
   addr_chk_timer.expires = jiffies_round_up(next);

could be an answer, but it is too lazy and not acceptable for me.
(Well, I don't need 100Hz but I want to have 3-10Hz at least.)

I'll make an alternative patch.

Regards,

--yoshfuji

