From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] tcp: tcp_make_synack() minor changes
Date: Wed, 26 Mar 2014 11:52:48 -0700
Message-ID: <1395859968.3726.32.camel@joe-AO722>
References: <1395853039.12610.217.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140326.142551.19958322633174107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0098.hostedemail.com ([216.40.44.98]:47200 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755896AbaCZSww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 14:52:52 -0400
In-Reply-To: <20140326.142551.19958322633174107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-26 at 14:25 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 26 Mar 2014 09:57:19 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > There is no need to allocate 15 bytes in excess for a SYNACK packet,
> > as it contains no data, only headers.
> > 
> > SYNACK are always generated in softirq context, and contain a single
> > segment, we can use TCP_INC_STATS_BH()
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>  ...
> > -	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
> > +	skb = sock_wmalloc(sk, MAX_TCP_HEADER, 1, GFP_ATOMIC);
> 
> Do you know where this "+ 15" comes from? :-)
> It is a kind of Linux networking trivia question.

It's really old, pre v1 days.
I presume it was some kind of ethernet minimum packet size padding.
