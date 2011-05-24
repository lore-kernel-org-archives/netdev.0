From: David Miller <davem@davemloft.net>
Subject: Re: bridge netfilter output bug on 2.6.39
Date: Tue, 24 May 2011 13:31:36 -0400 (EDT)
Message-ID: <20110524.133136.89503785066605635.davem@davemloft.net>
References: <20110524074156.58eb30f8@nehalam>
	<1306251543.3026.57.camel@edumazet-laptop>
	<1306254457.3026.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637Ab1EXRbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:31:42 -0400
In-Reply-To: <1306254457.3026.69.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 May 2011 18:27:37 +0200

> It seems bridge code uses one fake_rtable

Ugh, forgot about this turd. :-/

All route objects should be dynamically allocated, otherwise we'll
constantly have to attend to these static route instances when we make
any changes to dst_alloc() or similar.

I'll apply the fix you posted for now, but long term this code
needs to accomplish it's goals in a different way.
