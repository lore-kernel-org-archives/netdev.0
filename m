From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 20:27:20 +0400
Message-ID: <20060721162720.GA20549@2ka.mipt.ru>
References: <20060719131915.GA21942@ms2.inr.ac.ru> <20060720073223.GA15567@tservice.net.ru> <20060720164100.GA9213@ms2.inr.ac.ru> <20060720210849.GA28715@tservice.net.ru> <44BFF3F5.3040104@candelatech.com> <20060721071900.GB5151@2ka.mipt.ru> <44C0FD6F.5010601@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43945 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751082AbWGUQ13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 12:27:29 -0400
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <44C0FD6F.5010601@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2006 at 09:14:39AM -0700, Ben Greear (greearb@candelatech.com) wrote:
> >>Out of curiosity, is it possible to have the single producer logic
> >>if you have two+ ethernet interfaces handling frames for a single
> >>TCP connection?  (I am assuming some sort of multi-path routing
> >>logic...)
> >
> >I do not think it is possible with additional logic like what is
> >implemented in softirqs, i.e. per cpu queues of data, which in turn will
> >be converted into skbs one-by-one.
> 
> Couldn't you have two NICs being handled by two separate CPUs, with both
> CPUs trying to write to the same socket queue?
> 
> The receive path works with RCU locking from what I understand, so
> a protocol's receive function must be re-entrant.

There will not be socket queue on that stage - only per-cpu queues,
which then will be processed one-by-one by _exactly_ single user.
That user can get skb in round-robin manner and put them into socket
queue and call protocol receiving function.

> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com

-- 
	Evgeniy Polyakov
