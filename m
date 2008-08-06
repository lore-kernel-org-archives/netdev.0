From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2 proposal
Date: Wed, 06 Aug 2008 12:25:48 +0200
Message-ID: <48997C2C.8050208@trash.net>
References: <200808060125.38260.denys@visp.net.lb> <200808061304.45392.denys@visp.net.lb> <4899784C.5060405@trash.net> <200808061322.54655.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44834 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754181AbYHFKZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 06:25:51 -0400
In-Reply-To: <200808061322.54655.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> On Wednesday 06 August 2008, Patrick McHardy wrote:
> 
>> No patch attached ..
> 
> Sorry :-) Now must be attached

> +++ iproute2-patched/tc/m_mirred.c	2008-08-06 09:49:39.000000000 +0000
> @@ -27,6 +27,7 @@
>  #include <linux/tc_act/tc_mirred.h>
>  
>  int mirred_d = 1;
> +extern int link_cache;
>  
>  static void
>  explain(void)
> @@ -146,7 +147,10 @@
>  
>  	if (d[0])  {
>  		int idx;
> -		ll_init_map(&rth);
> +		if (!link_cache) {
> + 		    ll_init_map(&rth);
> +		    link_cache = 1;
> +		}

It would be nicer to avoid the initialization in ll_init_map() as
you did in your first patch and add an explicit ll_invalidate_map()
and call it when necessary (ip link add/del/change(?), ip tunnel
add/del/change(?)).
