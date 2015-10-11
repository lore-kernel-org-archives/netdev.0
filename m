From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix RFS vs lockless listeners
Date: Sun, 11 Oct 2015 05:33:53 -0700 (PDT)
Message-ID: <20151011.053353.955988140004407245.davem@davemloft.net>
References: <1444328208.27760.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, tom@herbertland.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbbJKMSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 08:18:01 -0400
In-Reply-To: <1444328208.27760.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Oct 2015 11:16:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Before recent TCP listener patches, we were updating listener
> sk->sk_rxhash before the cloning of master socket.
> 
> children sk_rxhash was therefore correct after the normal 3WHS.
> 
> But with lockless listener, we no longer dirty/change listener sk_rxhash
> as it would be racy.
> 
> We need to correctly update the child sk_rxhash, otherwise first data
> packet wont hit correct cpu if RFS is used.
> 
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Willem de Bruijn <willemb@google.com>
> Cc: Tom Herbert <tom@herbertland.com>

Applied, thanks Eric.
