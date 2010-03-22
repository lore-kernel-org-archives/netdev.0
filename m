From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: Gianfar: RX Recycle skb->len error
Date: Mon, 22 Mar 2010 20:24:46 +0300
Message-ID: <20100322172446.GA32758@oksana.dev.rtsoft.ru>
References: <A6A1774AFD79E346AE6D49A33CB294530DC19EB5@EX-BE-017-SFO.shared.themessagecenter.com>
 <20100321.214642.67901344.davem@davemloft.net>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: ben@bigfootnetworks.com, netdev@vger.kernel.org,
	Sandeep.Kumar@freescale.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:43956 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752062Ab0CVRYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 13:24:48 -0400
Content-Disposition: inline
In-Reply-To: <20100321.214642.67901344.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 21, 2010 at 09:46:42PM -0700, David Miller wrote:
[...]
> > 				 * recycle list.
> >  				 */
> >  				skb->data = skb->head + NET_SKB_PAD;
> > +				skb_reset_tail_pointer(skb);
> > 				__skb_queue_head(&priv->rx_recycle, skb);
> > 			}
> > 		} else {
> 
> This code is essentially trying to undo skb_reserve()
> but as you found it's doing so in a buggy manner.
> 
> skb_reserve() adjusts both the 'data' and 'tail' pointers,
> but this attempt at a reversal is only modifying 'data'.
> 
> Your fix is fine, but really any by-hand modification of
> skb->data is a bug, and we should provide an skb_unreserve()
> or similar to hide such details away, and use it here.
> 
> Anton?

Yes, skb_unreserve() (or skb_reset_reserved() for naming consistency?)
would be great.

Ben, note that ucc_geth.c driver is also affected by that bug,
so I guess it needs a similar fix.

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
