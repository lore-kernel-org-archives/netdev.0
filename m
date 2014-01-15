From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: avoid reference counter overflows on
 fib_rules in multicast forwarding
Date: Tue, 14 Jan 2014 17:40:46 -0800 (PST)
Message-ID: <20140114.174046.2032110531064031820.davem@davemloft.net>
References: <20140112074245.GF6586@order.stressinduktion.org>
	<1389574560.31367.197.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140113014522.GH6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, NetFestivalHaveFun@gmx.com, ja@ssi.bg,
	netdev@vger.kernel.org, kaber@trash.net, tgraf@suug.ch
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbaAOBkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 20:40:47 -0500
In-Reply-To: <20140113014522.GH6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 13 Jan 2014 02:45:22 +0100

> Bob Falken reported that after 4G packets, multicast forwarding stopped
> working. This was because of a rule reference counter overflow which
> freed the rule as soon as the overflow happend.
> 
> This patch solves this by adding the FIB_LOOKUP_NOREF flag to
> fib_rules_lookup calls. This is safe even from non-rcu locked sections
> as in this case the flag only implies not taking a reference to the rule,
> which we don't need at all.
> 
> Rules only hold references to the namespace, which are guaranteed to be
> available during the call of the non-rcu protected function reg_vif_xmit
> because of the interface reference which itself holds a reference to
> the net namespace.
> 
> Fixes: f0ad0860d01e47 ("ipv4: ipmr: support multiple tables")
> Fixes: d1db275dd3f6e4 ("ipv6: ip6mr: support multiple tables")
> Reported-by: Bob Falken <NetFestivalHaveFun@gmx.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, th anks.
