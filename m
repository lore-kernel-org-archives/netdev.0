From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 06/13] sis190: use netdev_alloc_skb
Date: Wed, 16 Apr 2008 19:59:01 -0700
Message-ID: <20080416195901.5a983217@speedy>
References: <20080416233727.732025083@vyatta.com>
	<20080416233757.391517921@vyatta.com>
	<4806B2FA.8020805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33325 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752562AbYDQC7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 22:59:08 -0400
In-Reply-To: <4806B2FA.8020805@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Apr 2008 10:16:26 +0800
Wang Chen <wangchen@cn.fujitsu.com> wrote:

> Stephen Hemminger said the following on 2008-4-17 7:37:
> > +static int sis190_try_rx_copy(struct net_device *dev,
> > +			      struct sk_buff **sk_buff, int pkt_size,
> > +			      struct RxDesc *desc, int rx_buf_sz)
> >  {
> > -	int ret = -1;
> > +	int ret = 01;
> >

Sorry, that was a typo.  meant to leave original -1

> why not : ret = 1
>   
> >  	if (pkt_size < rx_copybreak) {
> >  		struct sk_buff *skb;
> >  
> > -		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
> > +		skb = netdev_alloc_skb(dev, pkt_size + 2);
> >  		if (skb) {
> > -			skb_reserve(skb, NET_IP_ALIGN);
> > +			skb_reserve(skb, 2);
> 
> why?
> [PATCH 02/13] atl1: use netdev_alloc_skb
> using NET_IP_ALIGN, not 2.

NET_IP_ALIGN is defined as 0 on some platforms where cost of unaligned
DMA is greater than the cost of unaligned access. But in this case, the
driver is copying into the buffer, so the cost of unaligned DMA is not involved
so just align the data.
