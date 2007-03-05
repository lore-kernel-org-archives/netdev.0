From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : keep sk_backlog near sk_lock
Date: Sun, 04 Mar 2007 16:05:57 -0800 (PST)
Message-ID: <20070304.160557.63128876.davem@davemloft.net>
References: <20070222.012649.119274047.davem@davemloft.net>
	<200702221122.02806.dada1@cosmosbay.com>
	<200702221550.15280.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47507
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752554AbXCEAF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 19:05:58 -0500
In-Reply-To: <200702221550.15280.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 22 Feb 2007 15:50:15 +0100

> sk_backlog is a critical field of struct sock. (known famous words)
> 
> It is (ab)used in hot paths, in particular in release_sock(), tcp_recvmsg(), 
> tcp_v4_rcv(), sk_receive_skb().
> 
> It really makes sense to place it next to sk_lock, because sk_backlog is only 
> used after sk_lock locked (and thus memory cache line in L1 cache). This 
> should reduce cache misses and sk_lock acquisition time.
> 
> (In theory, we could only move the head pointer near sk_lock, and leaving tail 
> far away, because 'tail' is normally not so hot, but keep it simple :) )
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks a lot Eric.
