From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] gre: fix error handler
Date: Wed, 15 Jun 2016 22:15:33 -0700 (PDT)
Message-ID: <20160615.221533.906327416634459889.davem@davemloft.net>
References: <1465967701.7945.200.camel@edumazet-glaptop3.roam.corp.google.com>
	<1465969537.7945.201.camel@edumazet-glaptop3.roam.corp.google.com>
	<1465997040.7945.207.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org, tom@herbertland.com,
	maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbcFPFPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 01:15:34 -0400
In-Reply-To: <1465997040.7945.207.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Jun 2016 06:24:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> 1) gre_parse_header() can be called from gre_err()
> 
>    At this point transport header points to ICMP header, not the inner
> header.
> 
> 2) We can not really change transport header as ipgre_err() will later
> assume transport header still points to ICMP header (using icmp_hdr())
> 
> 3) pskb_may_pull() logic in gre_parse_header() really works
>   if we are interested at zone pointed by skb->data
> 
> 4) As Jiri explained in commit b7f8fe251e46 ("gre: do not pull header in
> ICMP error processing") we should not pull headers in error handler.
> 
> So this fix :
> 
> A) changes gre_parse_header() to use skb->data instead of
> skb_transport_header()
> 
> B) Adds a nhs parameter to gre_parse_header() so that we can skip the
> not pulled IP header from error path.
>   This offset is 0 for normal receive path.
> 
> C) remove obsolete IPV6 includes
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
