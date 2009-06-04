From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Wed, 03 Jun 2009 21:00:54 -0700 (PDT)
Message-ID: <20090603.210054.18839960.davem@davemloft.net>
References: <200906012157.29465.rusty@rustcorp.com.au>
	<4A26E4FD.5010405@gmail.com>
	<200906041324.59118.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, divy@chelsio.com,
	rolandd@cisco.com, xemul@openvz.org, dcbw@redhat.com,
	libertas-dev@lists.infradead.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39112
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750696AbZFDEAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 00:00:53 -0400
In-Reply-To: <200906041324.59118.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 4 Jun 2009 13:24:57 +0930

> On Thu, 4 Jun 2009 06:32:53 am Eric Dumazet wrote:
>> Also, taking a reference on socket for each xmit packet in flight is very
>> expensive, since it slows down receiver in __udp4_lib_lookup(). Several
>> cpus are fighting for sk->refcnt cache line.
> 
> Now we have decent dynamic per-cpu, we can finally implement bigrefs.  More 
> obvious for device counts than sockets, but perhaps applicable here as well?

It might be very beneficial for longer lasting, active, connections, but
for high connection rates it's going to be a lose in my estimation.
