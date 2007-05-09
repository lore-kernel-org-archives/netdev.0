From: David Miller <davem@davemloft.net>
Subject: Re: [1/1 take 2] Unified socket storage. (with small bench).
Date: Wed, 09 May 2007 03:02:00 -0700 (PDT)
Message-ID: <20070509.030200.123972145.davem@davemloft.net>
References: <20070509093443.GA10028@2ka.mipt.ru>
	<20070509.024445.71552569.davem@davemloft.net>
	<20070509095740.GB10028@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43769
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754963AbXEIKB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 06:01:59 -0400
In-Reply-To: <20070509095740.GB10028@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 9 May 2007 13:57:40 +0400

> That is only because we have very different way of working with udp.
> In udp hash table we can have multiple sockets bound to different ip
> addresses, but with the same port, so it will be placed into the same
> hash chain. With trie each socket will have differnet key, since
> addresses are different (or bound device number), so it automatically
> fixes problem with broken hash for udp (which is a bit fixed with
> extended hashing).

Yes it is power of trie.

So connection rates are interesting, but what about raw lookup
performance?  Last time this topic came up you went into some
cave when you looked at the trie lookup assembly and compared
it to hash. :)

It does make more memory references than hash by definition, and we
need to figure out whether that matters enough or not.
