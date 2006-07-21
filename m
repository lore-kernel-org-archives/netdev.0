From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 13:57:29 -0700 (PDT)
Message-ID: <20060721.135729.112616284.davem@davemloft.net>
References: <20060720225908.GA18362@ms2.inr.ac.ru>
	<20060720.215504.41641534.davem@davemloft.net>
	<44C10042.1020503@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50852
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751169AbWGUU51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 16:57:27 -0400
To: rick.jones2@hp.com
In-Reply-To: <44C10042.1020503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 21 Jul 2006 09:26:42 -0700

> > All this talk reminds me of one thing, how expensive tcp_ack() is.
> > And this expense has nothing to do with TCP really.  The main cost is
> > purging and freeing up the skbs which have been ACK'd in the
> > retransmit queue.
> > 
> > So tcp_ack() sort of inherits the cost of freeing a bunch of SKBs
> > which haven't been touched by the cpu in some time and are thus nearly
> > guarenteed to be cold in the cache.
> > 
> > This is the kind of work we could think about batching to user
> > sleeping on some socket call.
> 
> Ultimately isn't that just trying to squeeze the balloon?

In this case, the goal is not to eliminate the cost, but to
move it to user context so that it:

1) gets charged to the user instead of being lost in the ether of
   anonymous software interrupt execution, and more importantly...

2) it gets moved to the cpu where the user socket
   code is executing instead of the cpu where the ACK packet arrives
   which is basically arbitrary

#2 is in-line with the system level end-to-end principle goals of
netchannels.

