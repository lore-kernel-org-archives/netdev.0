From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] niu: RX queues should rotate if budget exhausted
Date: Fri, 27 Mar 2009 00:55:46 -0700 (PDT)
Message-ID: <20090327.005546.109440539.davem@davemloft.net>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
	<49CB8DFD.2050504@cosmosbay.com>
	<49CBC8CC.1090807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36381
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756652AbZC0Hz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:55:58 -0400
In-Reply-To: <49CBC8CC.1090807@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 26 Mar 2009 19:26:20 +0100

> I dont have NIU hardware but it seems this driver could suffer from 
> starvation of high numbered RX queues under flood. I suspect other
> multiqueue drivers might have same problem.
> 
> With a standard budget of 64, we can consume all credit when handling
> first queue(s), and last queues might discard packets.
> 
> Solve this by rotating the starting point, so that we garantee to scan at
> least one new queue at each niu_poll_core() invocation, even under stress.
> 
> Also, change logic calling niu_sync_rx_discard_stats() to take
> into account the device qlen, not bounded by budget (which could be 0)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

This change looks good to me, thanks for spotting this and
suggesting the fix.

It only hits people who don't have usable MSI-X interrupts,
and hey if you have one of these cards what are you doing
sticking it into such a machine :-)

Anyways, I'll apply this directly, thanks a lot!
