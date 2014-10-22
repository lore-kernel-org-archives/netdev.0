From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix saving TX flow hash in sock for outgoing
 connections
Date: Wed, 22 Oct 2014 16:15:00 -0400 (EDT)
Message-ID: <20141022.161500.808404293313816866.davem@davemloft.net>
References: <1413994321-20435-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932150AbaJVUPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 16:15:01 -0400
In-Reply-To: <1413994321-20435-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 22 Oct 2014 21:42:01 +0530

> The commit "net: Save TX flow hash in sock and set in skbuf on xmit"
> introduced the inet_set_txhash() and ip6_set_txhash() routines to calculate
> and record flow hash(sk_txhash) in the socket structure. sk_txhash is used
> to set skb->hash which is used to spread flows across multiple TXQs.
> 
> But, the above routines are invoked before the source port of the connection
> is created. Because of this all outgoing connections that just differ in the
> source port get hashed into the same TXQ.
> 
> This patch fixes this problem for IPv4/6 by invoking the the above routines
> after the source port is available for the socket.
> 
> Fixes: b73c3d0e4("net: Save TX flow hash in sock and set in skbuf on xmit")
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied and queued up for -stable, thanks.
