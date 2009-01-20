From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: RFC: Latency reducing TCP modifications for thin-stream     
 interactive applications
Date: Tue, 20 Jan 2009 17:45:52 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901201736370.1889@wrl-59.cs.helsinki.fi>
References: <496B59B7.3010302@simula.no>    <Pine.LNX.4.64.0901121705010.1889@wrl-59.cs.helsinki.fi>
 <e5152d316be79cafaf55fcf7bff64d46.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andreas Petlund <apetlund@simula.no>,
	Netdev <netdev@vger.kernel.org>, griff@simula.no,
	paalh@ifi.uio.no
To: kristrev@simula.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44660 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756253AbZATPpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 10:45:55 -0500
In-Reply-To: <e5152d316be79cafaf55fcf7bff64d46.squirrel@webmail.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trimmed all but netdev (and .no addresses) from cc list.

On Fri, 16 Jan 2009, kristrev@simula.no wrote:

> >> We have to admit we don't quite see the problem. Since a page can never
> >> be removed before all owners have decleared that they no longer needs
> >> it, all data will be correctly present. Also, since the packets are
> >> placed linearly on the queue and we don't support when SACK is enabled,
> >> no gaps will occur. But maybe we have misunderstood your comment, please
> >> let us know if that is the case.
> >
> > Yes, the problems _may_ arise because you create afaict:
> > skb->end_seq > next_skb->seq situations which is something that certainly
> > needs an audit over every single seqno operation to see that they don't
> > implicitly assume otherwise (ie., omit redundant compares)! There are
> > certainly places I know of already which will break... I'm afraid
> > that using the approach you've select you'll end up having very many
> > places needing some extra tweaking, that's why I suggested the alternative
> > approach to just construct the redundant things on-the-fly while keeping
> > the write queue as is.
> >
> 
> >> As far as we understand this comment, you want us to do it on the
> >> application layer instead? Do you mean as a middleware,
> >> application-specific solution or something similar? Also, we believe
> >> doing it on the application layer will lead to the same delays that we
> >> try to prevent, since sent data will be delayed on the transport layer
> >> in case of loss.
> >
> > No but at the time we're supposed to actually send an skb to the lower
> > layer and keeping the rest intact.
> 
> I have a small question regarding these two comments. Are you allowed to
> modify the packet data stored in a clone? Based on my understanding of the
> code and what a clone is, I thought the data was shared between the
> original and the clone. Thus, any data appended/inserted into the clone
> will also be appended to the original.

To avoid corruption you are not allowed to change data for cloned skbs.
...I'm not fully sure how this is related though.

> If I have understood the code correctly, what will then be the difference
> between our current solution and the one you suggest (except we can remove
> one of the bundling methods and when a packet is retransmitted)? If I have
> not understood the code correctly, feel free to yell :) (if it is a
> misunderstanding, it also explains all the checks for skb->cloned).

It didn't mean clone an skb but copy the relevant data into new skb which 
is then not put into write queue at all but given to lower layers only. 


-- 
 i.
