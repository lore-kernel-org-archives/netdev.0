From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/1] net: hold sock reference while processing tx
 timestamps
Date: Thu, 13 Oct 2011 10:54:43 +0200
Message-ID: <1318496083.5612.1.camel@jlt3.sipsolutions.net>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 (sfid-20111012_203706_058621_68EB8D6B) <1318447673.3933.47.camel@jlt3.sipsolutions.net>
	 <1318449159.2644.9.camel@edumazet-laptop>
	 (sfid-20111012_215313_649610_CEB1D4B5)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:34768 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747Ab1JMIyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 04:54:49 -0400
In-Reply-To: <1318449159.2644.9.camel@edumazet-laptop> (sfid-20111012_215313_649610_CEB1D4B5)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-12 at 21:52 +0200, Eric Dumazet wrote:

> > The other thing I was wondering -- what if we just set truesize to 1 (we
> > don't have any truesize checks) and account the skb to the socket
> > normally. Not really a good way either though.
> > 
> 
> Changing truesize is not allowed here see below.

Oh, good point.

> > FWIW I just decided to do it the other way around in mac80211 -- keep
> > the original SKB that's charged to the socket for the error queue, and
> > use a clone to actually do the TX.
> 
> Hmm, please take a look at IFF_SKB_TX_SHARING stuff, added in commit
> d88733150 (net: add IFF_SKB_TX_SHARED flag to priv_flags)

mac80211 got that flag cleared -- and right now I see no way to change
that. 11ac/ad may require work in this area to be able to do this
better, and I have a number of ideas on how to do that, but right now I
don't see how we can do that.

johannes
