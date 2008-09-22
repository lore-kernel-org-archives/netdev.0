From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Mon, 22 Sep 2008 08:40:52 +0400
Message-ID: <20080922044051.GA583@2ka.mipt.ru>
References: <20080922010834.GB3059@2ka.mipt.ru> <20080921.190715.144340989.davem@davemloft.net> <20080922041929.GA20165@2ka.mipt.ru> <20080921.212724.193719407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:33791 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764AbYIVEle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 00:41:34 -0400
Content-Disposition: inline
In-Reply-To: <20080921.212724.193719407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 09:27:24PM -0700, David Miller (davem@davemloft.net) wrote:
> > Datagram just preservs the boundaries and that's what we have with this
> > patch.
> 
> Not exactly.
> 
> Each and every send() operation on a datagram socket must result in
> exactly one packet.  sendfile() was following this rule, when it
> returned successfully only one single packet was emitted.
>
> The new sendfile() semantics are outside of this model.

That's for send(), not sendfile(). The latter now works like lots of
sends() while previously it worked as single send().

Why sendfile() should be completely different compared to stream case?
Obviously send() has to be different and it is, but sendfile() is just a
bunch of sends over the pages in the cache, so let's allow it to be
multiple sends and not only single packet send.

-- 
	Evgeniy Polyakov
