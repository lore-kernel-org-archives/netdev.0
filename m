From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: compound skb frag pages appearing in start_xmit
Date: Tue, 9 Oct 2012 15:40:30 +0100
Message-ID: <1349793630.21847.208.camel@zakaz.uk.xensource.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
	 <1349792241.21847.199.camel@zakaz.uk.xensource.com>
	 <1349792847.21172.4479.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	xen-devel <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:9693 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110Ab2JIOke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 10:40:34 -0400
In-Reply-To: <1349792847.21172.4479.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 15:27 +0100, Eric Dumazet wrote:
> On Tue, 2012-10-09 at 15:17 +0100, Ian Campbell wrote:
> 
> > Does the higher order pages effectively reduce the number of frags which
> > are in use? e.g if MAX_SKB_FRAGS is 16, then for order-0 pages you could
> > have 64K worth of frag data.
> > 
> > If we switch to order-3 pages everywhere then can the skb contain 512K
> > of data, or does the effective maximum number of frags in an skb reduce
> > to 2?
> 
> effective number of frags reduce to 2 or 3
> 
> (We still limit GSO packets to ~63536 bytes)

Great! Then I think the fix is more/less trivial...

As an aside, when the skb head is < 4096 bytes is that necessarily a
compound page or might it just be a large kmalloc area?

Only really relevant since it impacts the possibility for code sharing
between the head and the frags sending.

Ian
