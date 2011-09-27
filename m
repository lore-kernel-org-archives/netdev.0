From: Dave Jones <davej@redhat.com>
Subject: Re: __pskb_pull_tail oops from 2.6.35
Date: Tue, 27 Sep 2011 16:15:00 -0400
Message-ID: <20110927201500.GA27713@redhat.com>
References: <20110927200328.GA22678@redhat.com>
 <20110927.160804.528213323197711241.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1028 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493Ab1I0UPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Sep 2011 16:15:03 -0400
Content-Disposition: inline
In-Reply-To: <20110927.160804.528213323197711241.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2011 at 04:08:04PM -0400, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Tue, 27 Sep 2011 16:03:28 -0400
 > 
 > > A user just reported this on a fairly old kernel (running the latest -longterm patch).
 > > I had a look through net/core/skbuff.c since 2.6.35, and didn't see anything obvious.
 > > Does this look familiar to anyone ? 
 > 
 > I would say that something far outside of __pskb_pull_tail() is corrupting the
 > SKB state.  He has a bunch of netfilter stuff loaded so the possibilities are
 > endless :-)
 > 
 > Any chance to figure out exactly what NULL dereference happens inside of
 > __pskb_pull_tail()?

It looks like it died in put_page..

<1>[  262.574991] IP: [<ffffffff810dca57>] put_page+0x10/0x7c

which is only called in one place..

1267         for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
1268                 if (skb_shinfo(skb)->frags[i].size <= eat) {
1269                         put_page(skb_shinfo(skb)->frags[i].page);
1270                         eat -= skb_shinfo(skb)->frags[i].size;
1271                 } else {


	Dave
