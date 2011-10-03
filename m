From: Dave Jones <davej@redhat.com>
Subject: Re: __pskb_pull_tail oops from 2.6.35
Date: Mon, 3 Oct 2011 12:13:46 -0400
Message-ID: <20111003161346.GA30201@redhat.com>
References: <20110927200328.GA22678@redhat.com>
 <20110927.160804.528213323197711241.davem@davemloft.net>
 <20110927201500.GA27713@redhat.com>
 <20110927.161848.1967387021236457958.davem@davemloft.net>
 <20110927202405.GB27713@redhat.com>
 <1317155839.2472.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756673Ab1JCQNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Oct 2011 12:13:51 -0400
Content-Disposition: inline
In-Reply-To: <1317155839.2472.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2011 at 10:37:19PM +0200, Eric Dumazet wrote:
 
 > >  > > It looks like it died in put_page..
 > >  > > 
 > >  > > <1>[  262.574991] IP: [<ffffffff810dca57>] put_page+0x10/0x7c
 > >  > > 
 > >  > > which is only called in one place..
 > >  > > 
 > >  > > 1267         for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 > >  > > 1268                 if (skb_shinfo(skb)->frags[i].size <= eat) {
 > >  > > 1269                         put_page(skb_shinfo(skb)->frags[i].page);
 > >  > > 1270                         eat -= skb_shinfo(skb)->frags[i].size;
 > >  > > 1271                 } else {
 > >  > 
 > >  > That's a pretty serious corruption, all frag array entries from 0 to
 > >  > nr_frags should have valid, non-NULL page pointers.
 > >  > 
 > >  > Maybe a LRO/GRO bug?  There were a couple of those.
 > > 
 > > I'll see if I can talk him into trying a self-built kernel, as we're not
 > > rebasing f14 at this point in its life-cycle. If it turns out to still affect
 > > 3.x, I'll bring it up again.
 > 
 > This could be a struct skb_shared_info -> nr_frags corruption
 > 
 > (Something was overflowing skb head and overflowing very beginning of
 > skb_shared_info in rare circumstances)
 > 
 > We had such bug in the past, I cant remember details right now.

Just to close this discussion, the user reported that he built a 3.1.0rc7 kernel,
and couldn't reproduce this bug any more, so it was something that got fixed
that didn't make it to the longterm stable releases.

	Dave
