From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: replace macros net_random and net_srandom
 with direct calls to prandom
Date: Sat, 11 Jan 2014 09:52:37 -0800
Message-ID: <1389462757.2537.61.camel@joe-AO722>
References: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0054.hostedemail.com ([216.40.44.54]:48021 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751073AbaAKRwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 12:52:42 -0500
In-Reply-To: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-11 at 07:15 -0500, Aruna-Hewapathirane wrote:
> This patch removes the net_random and net_srandom macros and replaces
> them with direct calls to the prandom ones. As new commits only seem to
> use prandom_u32 there is no use to keep them around.
> This change makes it easier to grep for users of prandom_u32.

Seems sensible.

Also, there may be some value in a future patch
to use reciprocal_divide in a few places

> diff --git a/net/802/garp.c b/net/802/garp.c
> @@ -397,7 +397,7 @@ static void garp_join_timer_arm(struct garp_applicant *app)
>  {
>  	unsigned long delay;
>  
> -	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
> +	delay = (u64)msecs_to_jiffies(garp_join_time) * prandom_u32() >> 32;

reciprocal_divide()

> diff --git a/net/802/mrp.c b/net/802/mrp.c
[]
> @@ -583,7 +583,7 @@ static void mrp_join_timer_arm(struct mrp_applicant *app)
>  {
>  	unsigned long delay;
>  
> -	delay = (u64)msecs_to_jiffies(mrp_join_time) * net_random() >> 32;
> +	delay = (u64)msecs_to_jiffies(mrp_join_time) * prandom_u32() >> 32;

here too

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
[]
> @@ -223,7 +223,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
>  		inet_get_local_port_range(net, &low, &high);
>  		remaining = (high - low) + 1;
>  
> -		rand = net_random();
> +		rand = prandom_u32();
>  		first = (((u64)rand * remaining) >> 32) + low;

another
