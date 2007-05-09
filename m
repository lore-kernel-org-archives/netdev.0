From: David Miller <davem@davemloft.net>
Subject: Re: [1/1 take 2] Unified socket storage. (with small bench).
Date: Tue, 08 May 2007 23:48:28 -0700 (PDT)
Message-ID: <20070508.234828.95506666.davem@davemloft.net>
References: <20070508174331.GA13591@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50038
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S967745AbXEIGs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 02:48:27 -0400
In-Reply-To: <20070508174331.GA13591@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 8 May 2007 21:43:32 +0400

> This is second patch which implements unified cache of sockets for
> network instead of old hash tables. It stores all types of sockets
> (although I only implemented af_inet, unix, netlink and raw ones for now)
> in single object structure called multidimensional trie (which is
> similar to judy array in some way).

Thanks for doing this work it is very interesting. :)

> So, this is dynamic structure which can host any kind of network sockets
> (actually any structure pointer which can be addressed with 160 bits).
> Structure can be extended to support ipv6 (needs to increase key
> length) with essentially any number of elements in it.
> 
> Code is in development stage, but I would like to rise a discussion
> about needs to continue this development before next steps.

One thing that will need to be adjust for current tree is the UDP
hashing mechanism.  But as far as I can tell your code should be able
to handle the new scheme (we now hash UDP by saddr+port when
possible, and this reminds me that IPV6 is broken and needs some
repairs).

What exactly does the 'stages' arg mean?  Is this a method to handle
partially bound sockets?
