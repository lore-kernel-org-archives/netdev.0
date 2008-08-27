From: Andi Kleen <andi@firstfloor.org>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 18:56:35 +0200
Message-ID: <20080827165635.GY26610@one.firstfloor.org>
References: <200808220457.40892.denys@visp.net.lb> <20080826201406.GA24827@2ka.mipt.ru> <48B46B48.7030609@cosmosbay.com> <20080826205158.GA15266@2ka.mipt.ru> <87vdxmr53f.fsf@basil.nowhere.org> <48B57BD3.5050206@hp.com> <20080827162735.GW26610@one.firstfloor.org> <48B58586.3080806@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56256 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755013AbYH0QyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 12:54:03 -0400
Content-Disposition: inline
In-Reply-To: <48B58586.3080806@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 09:49:10AM -0700, Rick Jones wrote:
> Andi Kleen wrote:
> >>Those banks really want to crank down on latency - to the point they 
> >>start disabling interrupt coalescing.  I bet they'd toss anything out 
> >>they could to shave another microsecond.
> >
> >
> >This change would actually likely lower their latency.
> 
> I'm guessing you mean increase their latency?  I agree, it could - 
> depends entirely on the PPS in production I suspect.

No, moving the time stamps into the socket decreases latency
for all packets that don't need time stamps. And they likely 
have some packets which don't need time stamps too.

As a secondary effect if they use a RT kernel it might
be also beneficial to do the (depending on the platform)
costly time stamp in the lower priority socket context
than in the high priority interrupt thread.

-Andi

