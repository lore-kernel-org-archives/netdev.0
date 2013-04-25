From: David Miller <davem@davemloft.net>
Subject: Re: 3.6-rt: inet_sk_rx_dst_set() network splat
Date: Thu, 25 Apr 2013 00:36:47 -0400 (EDT)
Message-ID: <20130425.003647.679881018003461388.davem@davemloft.net>
References: <1366786204.5977.10.camel@marge.simpson.net>
	<1366853695.8964.120.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bitbucket@online.de, linux-rt-users@vger.kernel.org,
	netdev@vger.kernel.org, sfr@canb.auug.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667Ab3DYEgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 00:36:51 -0400
In-Reply-To: <1366853695.8964.120.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Apr 2013 18:34:55 -0700

> From: Eric Dumazet <edumazet@google.com>
 ...
> Thanks for the report, here is a fix.
> 
> It will be a bit of a hassle to merge this one on net-next, as
> tcp_prequeue() was moved in commit
> b2fb4f54ecd47c42413d54b4666b06cf93c05abf
> (tcp: uninline tcp_prequeue() )
> 
> David, maybe you prefer to pull into net tree the move, then I respin
> the fix ?
> 
> [PATCH] tcp: force a dst refcount when prequeue packet

I'll apply this to 'net', since you've explained the complict I now
know how to resolve this when I next merge into 'net-next'.

Stephen, there is a bug fix going into 'net' for tcp_prequeue()
however in 'net-next' tcp_prequeue() has simply moved from one
place to another.  The merge resolution is to simple move the
new skb_dst_force() call to the new location.
