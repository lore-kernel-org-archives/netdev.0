From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] TCP : keep copied_seq, rcv_wup and rcv_next together
Date: Thu, 22 Feb 2007 11:43:32 +0100
Message-ID: <200702221143.32622.dada1@cosmosbay.com>
References: <1171583205.29021.44.camel@localhost> <200702221122.02806.dada1@cosmosbay.com> <20070222.023220.92577095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:40373 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750726AbXBVKnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 05:43:43 -0500
In-Reply-To: <20070222.023220.92577095.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 22 February 2007 11:32, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 22 Feb 2007 11:22:02 +0100
>
> > rcv_wup and copied_seq should be next to rcv_nxt field, to lower number
> > of active cache lines in hot paths. (tcp_rcv_established(), tcp_poll(),
> > ...)
>
> Please fixup the assignment order in tcp_create_openreq_child() else
> we'll get a new store buffer stall during socket creation :-)

OK :)

I wonder if :

newtp->snd_nxt = newtp->snd_una = newtp->snd_sml = treq->snt_isn + 1;

is correct, since compiler will write snd_sml, then snd_una, and snd_nxt

Maybe we should also reorder this too ?

Eric
