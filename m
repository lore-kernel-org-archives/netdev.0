From: Dave Jones <davej@redhat.com>
Subject: Re: 8139cp dma-debug warning.
Date: Thu, 13 Aug 2009 15:28:40 -0400
Message-ID: <20090813192840.GA12838@redhat.com>
References: <20090806215702.GA17555@redhat.com> <20090812171333.GD3116@redhat.com> <20090812.222046.60033759.davem@davemloft.net> <20090813134549.GA2845@redhat.com> <20090813192326.GA32435@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40399 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753916AbZHMT2o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 15:28:44 -0400
Content-Disposition: inline
In-Reply-To: <20090813192326.GA32435@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2009 at 09:23:26PM +0200, Francois Romieu wrote:
 
 > > Below this, we're still doing an skb_reserve(NET_IP_ALIGN) on new_skb.
 > > Although the mapping is now constantly sized, aren't we still wastefully
 > > bumping the data/tail of the skb twice ?
 > 
 > $ grep -n NET_IP_ALIGN drivers/net/8139cp.c
 > 552:		new_skb = netdev_alloc_skb(dev, buflen + NET_IP_ALIGN);
 > 558:		skb_reserve(new_skb, NET_IP_ALIGN);
 > 1059:		skb = netdev_alloc_skb(dev, cp->rx_buf_sz + NET_IP_ALIGN);
 > 1063:		skb_reserve(skb, NET_IP_ALIGN);
 > 
 > I do not get it : netdev_alloc_skb allocates but it does not "bump" as
 > skb_reserve does (and skb_reserve does not allocate). Where would the
 > double bump come from ?
 > 
 > The mapping is constantly sized but we want the ethernet header following
 > IP data to be evenly aligned and thus the mapping to be oddly aligned.

Ah, now I get it. Thanks for the explanation :)

	Dave

