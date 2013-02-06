From: Cong Wang <amwang@redhat.com>
Subject: RE: [PATCH net-next v2] net: adjust skb_gso_segment() for calling
 in rx path
Date: Wed, 06 Feb 2013 17:30:32 +0800
Message-ID: <1360143032.23727.8.camel@cr0>
References: <1360118198-25440-1-git-send-email-amwang@redhat.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7138@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772Ab3BFJa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 04:30:57 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7138@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 09:23 +0000, David Laight wrote:
> > +/* openvswitch calls this on rx path, so we need a different check.
> > + */
> > +static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
> > +{
> > +	if (tx_path)
> > +		return skb->ip_summed != CHECKSUM_PARTIAL;
> > +	else
> > +		return skb->ip_summed == CHECKSUM_NONE;
> > +}
> > +
> 
> That code wants a lot of unlikely() added.
> 
> It seems wrong to be adding code a very common path for one
> obscure caller.

Its caller does:

+       if (unlikely(skb_needs_check(skb, tx_path))) {

> 
> Perhaps the caller should be modifying the ip_summed field
> (etc) to match the values expected for a tx skb.
> 

This is even uglier, you need to restore ip_summed after calling
skb_gso_segment().
