From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp_cubic: use 32 bit math
Date: Thu, 8 Mar 2007 05:16:28 +0100
Message-ID: <20070308041628.GA24530@1wt.eu>
References: <20070306145842.7d7fea84@freekitty> <20070307060838.GI943@1wt.eu> <20070307170731.2b4397e3@freekitty> <20070307.185539.48527371.davem@davemloft.net> <45EF7EB7.8040806@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1067 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751647AbXCHEVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 23:21:06 -0500
Content-Disposition: inline
In-Reply-To: <45EF7EB7.8040806@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2007 at 07:10:47PM -0800, Stephen Hemminger wrote:
> David Miller wrote:
> >From: Stephen Hemminger <shemminger@linux-foundation.org>
> >Date: Wed, 7 Mar 2007 17:07:31 -0800
> >
> >  
> >>The basic calculation has to be done in 32 bits to avoid
> >>doing 64 bit divide by 3. The value x is only 22bits max
> >>so only need full 64 bits only for x^2.
> >>
> >>Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> >>    
> >
> >Applied, thanks Stephen.
> >
> >What about Willy Tarreau's supposedly even faster variant?
> >Or does this incorporate that set of improvements?
> >  
> That's what this is:
>    x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x)) / 3;

Confirmed, it's the same. BTW, has someone tested on a 64bit system if
it brings any difference ?

Willy

