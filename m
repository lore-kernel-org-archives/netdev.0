From: Willy Tarreau <w@1wt.eu>
Subject: Re: tainted warnings with tcp splicing in 3.7.1
Date: Thu, 10 Jan 2013 08:21:36 +0100
Message-ID: <20130110072136.GK9943@1wt.eu>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan> <1357750898.27446.33.camel@edumazet-glaptop> <1357751372.27446.40.camel@edumazet-glaptop> <1357801149.27446.1142.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Becker <c.becker@traviangames.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:38180 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932211Ab3AJHVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 02:21:47 -0500
Content-Disposition: inline
In-Reply-To: <1357801149.27446.1142.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2013 at 10:59:09PM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> On Wed, 2013-01-09 at 09:09 -0800, Eric Dumazet wrote:
> 
> > My feeling is that tcp_recv_skb() should eat skbs instead of only
> > finding the right one
> > 
> 
> Thats indeed the case.
> 
> > Thats because skb_splice_bits() releases the socket lock before calling
> > splice_to_pipe()
> > 
> > Once socket is released, other incoming TCP frames can be processed, and
> > the skb we are actually processing might be 'collapsed' into smaller
> > units.
> > 
> > Christian, if I send you patches, are you OK to test them ?
> > 
> > 
> 
> Here is the patch fixing this issue.
> 
> Thanks a lot for your report, this is a very very old bug.
> 
> GRO being more deployed, and with TCP coalescing as well, chances to
> trigger this bug increased a lot.
> 
> To reproduce it, I had to force MSS=400 and stress the receiver,
> adding extra delays in skb_splice_bits() with socket lock being not
> held.

FWIW, I tested your patch here and did not notice any regression
compared to last week-end tests, at various MTU size combinations.

Cheers,
Willy
