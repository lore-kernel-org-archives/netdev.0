From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Sat, 01 Nov 2008 21:19:31 -0700 (PDT)
Message-ID: <20081101.211931.59267026.davem@davemloft.net>
References: <4908DEDE.5030706@cosmosbay.com>
	<49092891.5060603@acm.org>
	<49094B0F.2090208@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: minyard@acm.org, paulmck@linux.vnet.ibm.com, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl,
	johnpol@2ka.mipt.ru, christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48127
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750823AbYKBET4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 00:19:56 -0400
In-Reply-To: <49094B0F.2090208@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 30 Oct 2008 06:50:07 +0100

> [PATCH] udp: add a missing smp_wmb() in udp_lib_get_port()
> 
> Corey Minyard spotted a missing memory barrier in udp_lib_get_port()
> 
> We need to make sure a reader cannot read the new 'sk->sk_next' value
> and previous value of 'sk->sk_hash'. Or else, an item could be deleted
> from a chain, and inserted into another chain. If new chain was empty
> before the move, 'next' pointer is NULL, and lockless reader can
> not detect it missed following items in original chain.
> 
> This patch is temporary, since we expect an upcoming patch
> to introduce another way of handling the problem.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I've applied this to net-next-2.6
