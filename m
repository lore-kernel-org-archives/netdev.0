From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: properly update pmtu
Date: Wed, 22 Aug 2012 19:15:07 -0700 (PDT)
Message-ID: <20120822.191507.1479918004800745365.davem@davemloft.net>
References: <1345618109.5158.599.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg, s.munaut@whatever-company.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab2HWCPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 22:15:10 -0400
In-Reply-To: <1345618109.5158.599.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Aug 2012 08:48:29 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Sylvain Munault reported following info :
> 
>  - TCP connection get "stuck" with data in send queue when doing
>    "large" transfers ( like typing 'ps ax' on a ssh connection )
>  - Only happens on path where the PMTU is lower than the MTU of
>    the interface
>  - Is not present right after boot, it only appears 10-20min after
>    boot or so. (and that's inside the _same_ TCP connection, it works
>    fine at first and then in the same ssh session, it'll get stuck)
>  - Definitely seems related to fragments somehow since I see a router
>    sending ICMP message saying fragmentation is needed.
>  - Exact same setup works fine with kernel 3.5.1
> 
> Problem happens when the 10 minutes (ip_rt_mtu_expires) expiration
> period is over.
> 
> ip_rt_update_pmtu() calls dst_set_expires() to rearm a new expiration,
> but dst_set_expires() does nothing because dst.expires is already set.
> 
> It seems we want to set the expires field to a new value, regardless
> of prior one.
> 
> With help from Julian Anastasov.
> 
> Reported-by: Sylvain Munaut <s.munaut@whatever-company.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> CC: Julian Anastasov <ja@ssi.bg>

Applied, thanks.
