From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: RFC: Latency reducing TCP modifications for thin-stream       
    interactive applications
Date: Thu, 22 Jan 2009 16:13:19 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901221554240.1889@wrl-59.cs.helsinki.fi>
References: <496B59B7.3010302@simula.no>    <Pine.LNX.4.64.0901121705010.1889@wrl-59.cs.helsinki.fi>
    <e5152d316be79cafaf55fcf7bff64d46.squirrel@webmail.uio.no>   
 <Pine.LNX.4.64.0901201736370.1889@wrl-59.cs.helsinki.fi>
 <92d5db086b180f1241f7258fabae8f1b.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andreas Petlund <apetlund@simula.no>,
	Netdev <netdev@vger.kernel.org>, griff@simula.no,
	paalh@ifi.uio.no
To: kristrev@simula.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56244 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758146AbZAVONV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:13:21 -0500
In-Reply-To: <92d5db086b180f1241f7258fabae8f1b.squirrel@webmail.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jan 2009, kristrev@simula.no wrote:

> >> If I have understood the code correctly, what will then be the
> >> difference
> >> between our current solution and the one you suggest (except we can
> >> remove
> >> one of the bundling methods and when a packet is retransmitted)? If I
> >> have
> >> not understood the code correctly, feel free to yell :) (if it is a
> >> misunderstanding, it also explains all the checks for skb->cloned).
> >
> > It didn't mean clone an skb but copy the relevant data into new skb which
> > is then not put into write queue at all but given to lower layers only.
> 
> Thank you, now I understand what you meant and I agree that it is a better
> solution. However, when I think of it, copying might be too resource
> intensive and thus remove all gains from RDB. We have seen streams with 
> small packets and very low interarrival times, which would lead to a large
> number of copy-operations every second. I will implement it and compare
> performance.

The latencies caused by network related problems are hardly in the same 
order of magnitude than processing latencies due to simple alloc + copy of 
<= mss sized content, and if data is in frags you won't be copying even 
that much. For every avoided retransmission (with the associated rtt 
latency) you can copy a lot of data.

Ah, one more thing I already forgot earlier... Your solution is lacking 
means to deal with ambiguity problem which is a serious problem since
RTT measurements are valid only if there was not ambiguity.

-- 
 i.
