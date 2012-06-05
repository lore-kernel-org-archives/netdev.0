From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Tue, 05 Jun 2012 04:50:31 +0200
Message-ID: <1338864631.2760.1971.camel@edumazet-glaptop>
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
	 <20120604212050.GA2139@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43261 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757581Ab2FECuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 22:50:37 -0400
Received: by weyu7 with SMTP id u7so3269622wey.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 19:50:36 -0700 (PDT)
In-Reply-To: <20120604212050.GA2139@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 00:20 +0300, Michael S. Tsirkin wrote:
> On Mon, Jun 04, 2012 at 09:56:52PM +0200, Eric Dumazet wrote:
> > On Mon, 2012-06-04 at 22:48 +0300, Michael S. Tsirkin wrote:
> > 
> > > If I do this what will truesize be? 128, no?
> > 
> > My example was not correct, since you must have enough room for the
> > SKB_DATA_ALIGN(sizeof(struct skb_shared_info))  ( 320 bytes )
> > 
> > So it would be 128 + 320 = 448
> > 
> 
> 
> Ugh. I forgot about that. shinfo goes into the same page,
> so we'll have to also make all frags shorter by 320
> to leave space for shinfo at tail.
> overall looks like we need hyprevisor extensions if
> we want to use build_skb ...

Maybe not.

If you provided a 2048 bytes block and hypervisor filled one (small)
frame, there might be available room at the end of the block for the
shinfo already.

If yes : You can use build_skb()
If not : netdev_alloc_skb_ip_align()

I mentioned this trick for ixgbe driver.
