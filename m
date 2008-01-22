From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] dsmark: get rid of trivial function
Date: Mon, 21 Jan 2008 19:59:13 -0800 (PST)
Message-ID: <20080121.195913.256836460.davem@davemloft.net>
References: <4793E460.5020804@trash.net>
	<20080121.022223.85874858.davem@davemloft.net>
	<20080121194751.31fd42a0@speedy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44714
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753296AbYAVD7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 22:59:06 -0500
In-Reply-To: <20080121194751.31fd42a0@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Mon, 21 Jan 2008 19:47:51 -0800

> >  
> >  	indices = RTA_GET_U16(tb[TCA_DSMARK_INDICES-1]);
> > -	if (!indices || !dsmark_valid_indices(indices))
> > +
> > +	if (hweight32(indices) != 1)
> >  		goto errout;
> 
> Come on Dave, that is a step backwards.

Absolutely not.

> So you took a two instruction thing that any programmer who ever had
> one of those technical trick interviews would surely understand, and
> made it call a function...  Seems like the thing you would consul
> others against.

It's counting bits, "hamming weight" is a count of bits.

That is more understandable to me than:

	Oh BTW, power of two values also just so happen to
	have only 1 bit set.

Testing for a power of two obfuscates the meaning of the
test.  It doesn't want a power-of-two, it wants a bitmask
with only one bit set.
