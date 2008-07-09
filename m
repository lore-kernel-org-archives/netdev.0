From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: setsockopt()
Date: Wed, 9 Jul 2008 22:34:32 +0400
Message-ID: <20080709183432.GB5383@2ka.mipt.ru>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu> <20080707.144912.76654646.davem@davemloft.net> <20080708045443.GA7726@2ka.mipt.ru> <20080708020235.388a7bd5.billfink@mindspring.com> <adar6a4x510.fsf@cisco.com> <20080708144817.3c364962.billfink@mindspring.com> <ada63rfrkrs.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:35995 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753582AbYGISf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 14:35:58 -0400
Content-Disposition: inline
In-Reply-To: <ada63rfrkrs.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2008 at 11:10:31AM -0700, Roland Dreier (rdreier@cisco.com) wrote:
> so somehow setting the window helps with the scheduling of
> processes... I guess autotuning lets some queue get too long or
> something like that.  The actual window doesn't matter too much, since
> the delay of the network is low enough that even though the bandwidth is
> very high, the BDP is quite small.  (With a 25 usec RTT, a 128 KB window
> should be enough for 40 Gbps, well over the raw link speed of 16 Gbps
> that I have)

That may be cache issues: depending on what application does it can be
useful or not to be bound to the same CPU. I suppose if benchmark looks
into the packet content, then it likely wants to be on the same CPU to
aliminate cache line ping-pongs, otherwise it only needs to be awakened
to send/receive next chunk, so having it on different CPU may result in
better its utilization...

-- 
	Evgeniy Polyakov
