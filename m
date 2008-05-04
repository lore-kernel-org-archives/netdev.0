From: David Miller <davem@davemloft.net>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 15:38:43 -0700 (PDT)
Message-ID: <20080504.153843.218230160.davem@davemloft.net>
References: <20080504021213.GA30660@gondor.apana.org.au>
	<1209867740.6210.46.camel@johannes.berg>
	<20080504031652.GA30993@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753537AbYEDWio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 18:38:44 -0400
In-Reply-To: <20080504031652.GA30993@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 4 May 2008 11:16:52 +0800

> On Sun, May 04, 2008 at 04:22:20AM +0200, Johannes Berg wrote:
> >
> > Yes, wireless always needs at least 24 bytes, but more likely 34
> > (encryption+QoS). However, I just increased LL_MAX_HEADER to 54 and that
> > doesn't seem to have helped.
> 
> How did you test it?

I know what causes this problem, things like ARP.

They don't use LL_MAX_HEADER, and instead go:

	skb = alloc_skb(arp_hdr_len(dev) + LL_RESERVED_SPACE(dev), GFP_ATOMIC);

because they are reasonably sure what exact device they
are sending out of :-)

As mentioned elsewhere, there is a disconnect between how some
of these values are used.  But I'm pretty sure I know why some
of them are used this way.
