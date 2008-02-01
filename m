From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 05:31:13 +0100
Message-ID: <20080201043113.GA10720@one.firstfloor.org>
References: <20080131124632.GA25299@basil.nowhere.org> <47A212CB.1060403@hp.com> <20080131190326.GF4671@one.firstfloor.org> <47A214FE.3050200@hp.com> <20080131192521.GG4671@one.firstfloor.org> <47A21E1A.6000006@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53318 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756099AbYBAD4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 22:56:48 -0500
Content-Disposition: inline
In-Reply-To: <47A21E1A.6000006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 11:14:34AM -0800, Rick Jones wrote:
> Sounds like the functionality needs to be in the DSL bridge :) (or the 
> "router" in the same case) Particularly since it might be getting used 
> by more than one host on the GbE switch.

Possible, but it is not usually in the real world. Setups like
WonderShaper which do this on the host side are pretty common.

> then the qdisc could/should place a cap on the size of a 'TSO' based on 
> the bitrate (and perhaps input as to how much time any one "burst" of 
> data should be allowed to consume on the network) and pass that up the 
> stack?  right now you seem to be proposing what is effectively a cap of 
> 1 MSS.

Hmm, that would probably be possible for TBF, but I'm not sure this can be
really done in a useful way for the more complicated qdiscs. Especially
since they would likely need to turn on/off GSO regularly when dynamic
circumstances change and there is not really a good way to affect a socket 
after it was created.

-Andi
