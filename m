From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: only create late gso-skb if skb is already
 set up with CHECKSUM_PARTIAL
Date: Wed, 24 Feb 2016 14:13:00 -0500 (EST)
Message-ID: <20160224.141300.658238403360268304.davem@davemloft.net>
References: <1456163005-15809-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com, wakko@animx.eu.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbcBXTNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 14:13:04 -0500
In-Reply-To: <1456163005-15809-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 22 Feb 2016 18:43:25 +0100

> Otherwise we break the contract with GSO to only pass CHECKSUM_PARTIAL
> skbs down. This can easily happen with UDP+IPv4 sockets with the first
> MSG_MORE write smaller than the MTU, second write is a sendfile.
> 
> Returning -EOPNOTSUPP lets the callers fall back into normal sendmsg path,
> were we calculate the checksum manually during copying.
> 
> Commit d749c9cbffd6 ("ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked
> sockets") started to exposes this bug.
> 
> Fixes: d749c9cbffd6 ("ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked sockets")
> Reported-by: Jiri Benc <jbenc@redhat.com>
> Cc: Jiri Benc <jbenc@redhat.com>
> Reported-by: Wakko Warner <wakko@animx.eu.org>
> Cc: Wakko Warner <wakko@animx.eu.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
