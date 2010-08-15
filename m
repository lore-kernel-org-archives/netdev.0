From: David Miller <davem@davemloft.net>
Subject: Re: GTSM and TCP accept problem
Date: Sat, 14 Aug 2010 22:12:58 -0700 (PDT)
Message-ID: <20100814.221258.35029372.davem@davemloft.net>
References: <20100814214634.24a87715@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33778
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751006Ab0HOFMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 01:12:40 -0400
In-Reply-To: <20100814214634.24a87715@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 14 Aug 2010 21:46:34 -0400

> The implementation of Generalized TTL Security has a problem
> on the TCP accept side. Since there can be different number of
> hops for each peer, the listener ends up doing
> 
>    socket
>    bind
>    set TTL to 255
>    listen
>    while (nfd = accept(peer)) {
>      info = lookup(peer)
>      set MINTTL to 255 - info->ttl_hops

Surely when creating the initial listening socket we should use the
minimum TTL over the set of peers right?

That surely takes most of the fun out of this problem for the
attacker.
