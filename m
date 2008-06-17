From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] netns: optimize tcp and udp hashtables
 wrt net namespaces
Date: Mon, 16 Jun 2008 17:14:59 -0700 (PDT)
Message-ID: <20080616.171459.40244811.davem@davemloft.net>
References: <485633E4.10900@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55268
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750931AbYFQAO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 20:14:59 -0400
In-Reply-To: <485633E4.10900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 16 Jun 2008 13:35:32 +0400

> Currently hash functions to store udp sockets, bind buckets,
> listening and established tcp sockets take only ports and/or
> addresses into account.
> 
> The result is nasty. Consider processes in different namespaces
> communicate to each other or the outer world with same ports 
> or addresses (e.g. dns server run in each namespace, apache server
> listening a 80 port in each ns or communications via lo). All 
> these sockets will all be linked in a single hash chain, thus 
> producing too long chains.
> 
> To avoid this situation the proposal is to add some "salt" to
> hash functions taking the namespace into account.
> 
> I made this "salt" disappear for CONFIG_NET_NS=n case.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Looks great.  I've applied this to net-next-2.6 and will push
back out to kernel.org after some build testing.

Thanks!
