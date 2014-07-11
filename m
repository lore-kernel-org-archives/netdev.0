From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH for stable 3.10] xen-netback: drop SKB from
 internal queue if frontend is disconnected
Date: Fri, 11 Jul 2014 17:38:50 +0100
Message-ID: <20140711163850.GJ12584@zion.uk.xensource.com>
References: <1405084112-8134-1-git-send-email-wei.liu2@citrix.com>
 <53BFED2F.7070002@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, Ian Campbell <ian.campbell@citrix.com>,
	Philipp Hahn <hahn@univention.de>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:28474 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbaGKQiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 12:38:52 -0400
Content-Disposition: inline
In-Reply-To: <53BFED2F.7070002@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 11, 2014 at 02:57:03PM +0100, David Vrabel wrote:
> On 11/07/14 14:08, Wei Liu wrote:
> > 
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -720,6 +720,16 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
> >  		vif = netdev_priv(skb->dev);
> >  		nr_frags = skb_shinfo(skb)->nr_frags;
> >  
> > +		/* In rare case that frontend is disconnected while
> > +		 * there's still SKBs stuck in netback internal
> > +		 * rx_queue, drop these SKBs.
> > +		 */
> > +		if (unlikely(!vif->ring_mapped)) {
> > +			dev_kfree_skb(skb);
> > +			xenvif_put(vif);
> > +			continue;
> > +		}
> 
> Is this racy?  The ring may be unmapped after the test but before we put
> responses on it.
> 

Hmm... there's still a window. Ignore this patch for now. I will need to
look further into a ref-counting solution.

Wei.

> David
