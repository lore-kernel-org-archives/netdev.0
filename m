From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: fix potential NULL deref in
 __inet_inherit_port()
Date: Wed, 14 Oct 2015 19:08:57 -0700 (PDT)
Message-ID: <20151014.190857.731591055724929995.davem@davemloft.net>
References: <1444827518.4166.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633AbbJOBwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 21:52:55 -0400
In-Reply-To: <1444827518.4166.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Oct 2015 05:58:38 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> As we no longer hold listener lock in fast path, it is possible that a
> child is created right after listener freed its bound port, if a close()
> is done while incoming packets are processed.
> 
> __inet_inherit_port() must detect this and return an error,
> so that caller can free the child earlier.
> 
> Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
