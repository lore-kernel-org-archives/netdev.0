From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] sctp: Enforce maximum retransmissions during shutdown
Date: Thu, 30 Jun 2011 12:17:03 -0400
Message-ID: <20110630161703.GC24074@canuck.infradead.org>
References: <20110629135704.GB10085@canuck.infradead.org>
 <4E0B3491.1060603@hp.com>
 <20110629143649.GC10085@canuck.infradead.org>
 <4E0B3DA1.9060200@hp.com>
 <20110629154814.GD10085@canuck.infradead.org>
 <4E0B4F71.4020108@hp.com>
 <20110630084933.GA24074@canuck.infradead.org>
 <4E0C8368.5090502@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:57990 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115Ab1F3QRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 12:17:07 -0400
Content-Disposition: inline
In-Reply-To: <4E0C8368.5090502@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2011 at 10:08:40AM -0400, Vladislav Yasevich wrote:
> How about this.  If we in SHUTDOWN_PENDING state, let the errors accumulate upto
> max_retrans.  After that, start SHUTDOWN_GUARD timer to let the association live a
> bit longer just on the off-chance the receive comes back.  When SHUTDOWN_GUARD
> expires it will abort the association.
> 
> When we are in this state, SACK processing will have to reset SHUTDOWN_GUARD when
> the SACK is actually acknowledging something.

Good idea. I'll update my patch.

> > 
> > What sideeffects are you worried about resulting from my proposal?
> > 
> 
> There is a potential that the sender may abort prematurely.  The issue is that
> the sender has no way of knowing if the remote process somehow terminated and
> will never consume data, or if it is just extremely busy with something else and
> will come back.  Since this is a reliable protocol, we given the receive the benefit
> of the doubt and try our hardest to get the data across.

Understood although we are talking 10 * RTO here without an actual SACK.

> My suggestion above is still a bit of a hack that one could argue still violates the
> protocol, but the time period tries to remove as much doubt from the sender as possible
> the the receiver is really out-to-lunch.

Assuming that by 'shutdown sequence' the spec is only referring to the
SHUTDOWN / SHUTDOWN ACK exchange it would still violate the protocol
but I don't see how to avoid having association hang around forever without
violating the spec. This really looks like a hole in the spec to me.
