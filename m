From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP_USER_TIMEOUT: a new socket option to specify max
 timeout before a TCP connection is aborted
Date: Sat, 28 Aug 2010 16:13:20 -0700 (PDT)
Message-ID: <20100828.161320.245404727.davem@davemloft.net>
References: <1282972408-19164-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	hagen@jauu.net, lars.eggert@nokia.com, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58736
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751244Ab0H1XNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 19:13:04 -0400
In-Reply-To: <1282972408-19164-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Fri, 27 Aug 2010 22:13:28 -0700

> @@ -556,7 +559,14 @@ static void tcp_keepalive_timer (unsigned long data)
>  	elapsed = keepalive_time_elapsed(tp);
>  
>  	if (elapsed >= keepalive_time_when(tp)) {
> -		if (icsk->icsk_probes_out >= keepalive_probes(tp)) {
> +		/* If the TCP_USER_TIMEOUT option is enabled, use that
> +		 * to determine when to timeout instead.
> +		 */
> +		if ((icsk->icsk_user_timeout != 0 &&
> +		    elapsed >= icsk->icsk_user_timeout &&
> +		    icsk->icsk_probes_out > 0) ||
> +		    (icsk->icsk_user_timeout == 0 &&
> +		    icsk->icsk_probes_out >= keepalive_probes(tp))) {
>  			tcp_send_active_reset(sk, GFP_ATOMIC);
>  			tcp_write_err(sk);
>  			goto out;

I think if we want to add a socket option which overrides, it makes
more sense to provide overrides in the same units.  This
transformation here is transforming a check against apples into a
check against oranges.

But if that's how this thing is specified, so be it... I guess. :-/

