From: David Miller <davem@davemloft.net>
Subject: Re: __pskb_pull_tail oops from 2.6.35
Date: Tue, 27 Sep 2011 16:18:48 -0400 (EDT)
Message-ID: <20110927.161848.1967387021236457958.davem@davemloft.net>
References: <20110927200328.GA22678@redhat.com>
	<20110927.160804.528213323197711241.davem@davemloft.net>
	<20110927201500.GA27713@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376Ab1I0USv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 16:18:51 -0400
In-Reply-To: <20110927201500.GA27713@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 27 Sep 2011 16:15:00 -0400

> It looks like it died in put_page..
> 
> <1>[  262.574991] IP: [<ffffffff810dca57>] put_page+0x10/0x7c
> 
> which is only called in one place..
> 
> 1267         for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> 1268                 if (skb_shinfo(skb)->frags[i].size <= eat) {
> 1269                         put_page(skb_shinfo(skb)->frags[i].page);
> 1270                         eat -= skb_shinfo(skb)->frags[i].size;
> 1271                 } else {

That's a pretty serious corruption, all frag array entries from 0 to
nr_frags should have valid, non-NULL page pointers.

Maybe a LRO/GRO bug?  There were a couple of those.
