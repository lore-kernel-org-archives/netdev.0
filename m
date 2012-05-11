From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 1/6] skbuff: support per-page destructors in
 copy_ubufs
Date: Fri, 11 May 2012 17:12:02 -0400 (EDT)
Message-ID: <20120511.171202.1845086514372654549.davem@davemloft.net>
References: <1336726800.23818.33.camel@zakaz.uk.xensource.com>
	<1336733892.23818.69.camel@zakaz.uk.xensource.com>
	<20120511120836.GA4637@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932903Ab2EKVMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 17:12:09 -0400
In-Reply-To: <20120511120836.GA4637@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Fri, 11 May 2012 15:08:37 +0300

> On Fri, May 11, 2012 at 11:58:12AM +0100, Ian Campbell wrote:
>> On Fri, 2012-05-11 at 10:00 +0100, Ian Campbell wrote:
>> > I'm seeing copy_ubufs called in my remote NFS test, which I don't
>> > think I expected -- I'll investigate why this is happening today. 
>> 
>> It's tcp_transmit_skb which can (conditionally) call skb_clone
>> (backtrace below)
> 
> Interesting. I didn't realise we clone skbs on data path:
> tcp_write_xmit calls tcp_transmit_skb with clone_it flag.
> Could someone comment on why we need to clone on good path
> like this?

We can't send the original SKB that's linked into the retransmit
queue.  It's linkage must stay secure in that queue.
