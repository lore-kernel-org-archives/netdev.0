From: Dave Jones <davej@redhat.com>
Subject: Re: __pskb_pull_tail oops from 2.6.35
Date: Tue, 27 Sep 2011 16:24:05 -0400
Message-ID: <20110927202405.GB27713@redhat.com>
References: <20110927200328.GA22678@redhat.com>
 <20110927.160804.528213323197711241.davem@davemloft.net>
 <20110927201500.GA27713@redhat.com>
 <20110927.161848.1967387021236457958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49599 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752061Ab1I0UYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Sep 2011 16:24:08 -0400
Content-Disposition: inline
In-Reply-To: <20110927.161848.1967387021236457958.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2011 at 04:18:48PM -0400, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Tue, 27 Sep 2011 16:15:00 -0400
 > 
 > > It looks like it died in put_page..
 > > 
 > > <1>[  262.574991] IP: [<ffffffff810dca57>] put_page+0x10/0x7c
 > > 
 > > which is only called in one place..
 > > 
 > > 1267         for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 > > 1268                 if (skb_shinfo(skb)->frags[i].size <= eat) {
 > > 1269                         put_page(skb_shinfo(skb)->frags[i].page);
 > > 1270                         eat -= skb_shinfo(skb)->frags[i].size;
 > > 1271                 } else {
 > 
 > That's a pretty serious corruption, all frag array entries from 0 to
 > nr_frags should have valid, non-NULL page pointers.
 > 
 > Maybe a LRO/GRO bug?  There were a couple of those.

I'll see if I can talk him into trying a self-built kernel, as we're not
rebasing f14 at this point in its life-cycle. If it turns out to still affect
3.x, I'll bring it up again.

	Dave
