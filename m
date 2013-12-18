From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: pmtudisc setting not respected with UFO/CORK
Date: Wed, 18 Dec 2013 17:53:03 -0500 (EST)
Message-ID: <20131218.175303.1726920497652378353.davem@davemloft.net>
References: <20131216113644.GB2215@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146Ab3LRWxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 17:53:05 -0500
In-Reply-To: <20131216113644.GB2215@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 16 Dec 2013 12:36:44 +0100

> Sockets marked with IPV6_PMTUDISC_PROBE (or later IPV6_PMTUDISC_INTERFACE)
> don't respect this setting when the outgoing interface supports UFO.
> 
> We had the same problem in IPv4, which was fixed in commit
> daba287b299ec7a2c61ae3a714920e90e8396ad5 ("ipv4: fix DO and PROBE pmtu
> mode regarding local fragmentation with UFO/CORK").
> 
> Also IPV6_DONTFRAG mode did not care about already corked data, thus
> it may generate a fragmented frame even if this socket option was
> specified. It also did not care about the length of the ipv6 header and
> possible options.
> 
> In the error path allow the user to receive the pmtu notifications via
> both, rxpmtu method or error queue. The user may opted in for both,
> so deliver the notification to both error handlers (the handlers check
> if the error needs to be enqueued).
> 
> Also report back consistent pmtu values when sending on an already
> cork-appended socket.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, applied, thanks!
