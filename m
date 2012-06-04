From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Tue, 5 Jun 2012 00:20:50 +0300
Message-ID: <20120604212050.GA2139@redhat.com>
References: <20120604134138.GA29814@redhat.com>
 <1338818501.2760.1821.camel@edumazet-glaptop>
 <20120604141731.GA30226@redhat.com>
 <1338822064.2760.1834.camel@edumazet-glaptop>
 <20120604172030.GA32205@redhat.com>
 <1338831890.2760.1842.camel@edumazet-glaptop>
 <20120604181636.GG32205@redhat.com>
 <1338837842.2760.1883.camel@edumazet-glaptop>
 <20120604194806.GB1648@redhat.com>
 <1338839812.2760.1939.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752373Ab2FDV3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 17:29:01 -0400
Content-Disposition: inline
In-Reply-To: <1338839812.2760.1939.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 04, 2012 at 09:56:52PM +0200, Eric Dumazet wrote:
> On Mon, 2012-06-04 at 22:48 +0300, Michael S. Tsirkin wrote:
> 
> > If I do this what will truesize be? 128, no?
> 
> My example was not correct, since you must have enough room for the
> SKB_DATA_ALIGN(sizeof(struct skb_shared_info))  ( 320 bytes )
> 
> So it would be 128 + 320 = 448
> 


Ugh. I forgot about that. shinfo goes into the same page,
so we'll have to also make all frags shorter by 320
to leave space for shinfo at tail.
overall looks like we need hyprevisor extensions if
we want to use build_skb ...
