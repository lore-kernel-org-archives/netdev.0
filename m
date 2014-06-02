From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix inet_getid() and ipv6_select_ident() bugs
Date: Mon, 02 Jun 2014 14:10:13 -0700 (PDT)
Message-ID: <20140602.141013.742158259109147373.davem@davemloft.net>
References: <1401378314.3645.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173AbaFBVKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 17:10:14 -0400
In-Reply-To: <1401378314.3645.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 May 2014 08:45:14 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I noticed we were sending wrong IPv4 ID in TCP flows when MTU discovery
> is disabled.
> Note how GSO/TSO packets do not have monotonically incrementing ID. 
> 
> 06:37:41.575531 IP (id 14227, proto: TCP (6), length: 4396)
> 06:37:41.575534 IP (id 14272, proto: TCP (6), length: 65212)
> 06:37:41.575544 IP (id 14312, proto: TCP (6), length: 57972)
> 06:37:41.575678 IP (id 14317, proto: TCP (6), length: 7292)
> 06:37:41.575683 IP (id 14361, proto: TCP (6), length: 63764)
> 
> It appears I introduced this bug in linux-3.1.
> 
> inet_getid() must return the old value of peer->ip_id_count,
> not the new one.
> 
> Lets revert this part, and remove the prevention of
> a null identification field in IPv6 Fragment Extension Header,
> which is dubious and not even done properly.
> 
> Fixes: 87c48fa3b463 ("ipv6: make fragment identifications less predictable")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks for the heads up about the
merge conflict with net-next.
