From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Tue, 18 Dec 2012 16:22:38 +0000
Message-ID: <1355847758.14620.265.camel@zakaz.uk.xensource.com>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com>
	 <1355843525.9380.18.camel@edumazet-glaptop>
	 <1355844398.14620.254.camel@zakaz.uk.xensource.com>
	 <1355847180.9380.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:15920 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754980Ab2LRQWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 11:22:48 -0500
In-Reply-To: <1355847180.9380.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 16:13 +0000, Eric Dumazet wrote:
> On Tue, 2012-12-18 at 15:26 +0000, Ian Campbell wrote:
> 
> > So actually we want += PAGE_SIZE * skb_shinfo(skb)->nr_frags ?
> > 
> 
> I dont know what are the real frag sizes in your case.

I think it's a page, see xennet_alloc_rx_buffers and the alloc_page
therein.

> Some drivers allocate a full page for an ethernet frame, others use half
> of a page, it really depends.
> 
> As the frag ABI doesnt contain real size, its ok in this case to account
> the actual frag size.
> 
> (skb->data_len in your driver)

I guess I'm a bit confused by what truesize means again then ;-),
because in that case the original patch is correct although it would
have been less confusing to do:
	skb->truesize += skb->data_len; 
in xennet_poll() and then do the subtraction of
NETFRONT_SKB_CB(skb)->pull_to in handle_incoming_queue() where we
actually do the pull up.

Unless __pskb_pull_tail does that adjustment for us, but if it does I
can't see where.

Ian.
