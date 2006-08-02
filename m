From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Wed, 02 Aug 2006 02:24:43 +0200
Message-ID: <m37j1sc7ck.fsf@defiant.localdomain>
References: <m3r701zgku.fsf@defiant.localdomain>
	<20060731.132324.65197403.davem@davemloft.net>
	<m3fyghz2oz.fsf@defiant.localdomain>
	<20060731.181314.27783697.davem@davemloft.net>
	<m3bqr5z0ah.fsf@defiant.localdomain>
	<20060801195431.GA29335@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45528 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1750767AbWHBAYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 20:24:47 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060801195431.GA29335@ms2.inr.ac.ru> (Alexey Kuznetsov's message of "Tue, 1 Aug 2006 23:54:31 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> writes:

> As I already said there is nothing wrong with the first chunk.
> Except that it hides the real problem.

The problem is already very well hidden :-) I have seen just two
reports of this problem since 1994, and I believe both of them
were related to a device without hard_header() (i.e., it probably
wouldn't show with the patch applied).
I have never seen this problem personally, and I've been using
FR for about 10 years (in 1-3 locations - though I think at first it
did use hard_header()).


How about the second part of the patch? I know the second part isn't
related to kernel panic but don't you think hard_header_len
should be treated uniformly across the tree (i.e., shouldn't depend
on hard_header() being non-NULL)?

If not, fine.

> Do not get it wrong. dev->hard_header_len is _NEVER_ guaranteed.
> The places, which allocate skb, take it as a hint to avoid reallocation.
> But each place which stuffs something at head, still must check the space.
>
> The only difference between the situation with dev->hard_header,
> is that when dev->hard_header != NULL, the header is added by IP itself.
> That's why IP checks it.

Do you mean IP calls hard_header() which, in turn, does skb_push()?

How about Ethernet - is it safe? There is hard_header() which blindly
adds 14 bytes.
-- 
Krzysztof Halasa
