From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Fri, 23 May 2008 16:00:41 +0400
Message-ID: <20080523120041.GA16850@2ka.mipt.ru>
References: <20080522181401.GA14056@2ka.mipt.ru> <31256957387BB54C8B9AFE88AA5C0564044A1846@SDCEXCHANGE01.ad.amcc.com> <20080522184906.GA32582@2ka.mipt.ru> <20080522.115755.202204829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kchudgar@amcc.com, kchudgar.linux@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:48996 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457AbYEWMBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2008 08:01:09 -0400
Content-Disposition: inline
In-Reply-To: <20080522.115755.202204829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 22, 2008 at 11:57:55AM -0700, David Miller (davem@davemloft.net) wrote:
> > You have to copy part of the data (up to and including transport headers)
> > into skb->data.
> 
> You don't necessarily have to.  The input paths of the networking
> stack will pull into the skb->data, as needed, using
> pskb_may_pull() calls.
> 
> I did some tests with the NIU driver on receive, and to be
> honest there was nearly zero performance gain from pre-copying
> into skb->data from the paged SKB area preemptively before
> passing the packet in via netif_receive_skb().

Well, yes, essentially there should not be major difference who will
copy that bits into skb->data when/if needed, although MAC header has
to be there oterwise eth_type_trans() will not work, it does plain
skb_pull(). If eth_type_trans() is not used (there is some way to know
protocol number) things should be ok without copy (?)

So, from perfomance viewpoint it looks like the best decision is to
have first part of the packet in skb->data and the rest in attached
pages.

-- 
	Evgeniy Polyakov
