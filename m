From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Tue, 1 Aug 2006 23:54:31 +0400
Message-ID: <20060801195431.GA29335@ms2.inr.ac.ru>
References: <m3r701zgku.fsf@defiant.localdomain> <20060731.132324.65197403.davem@davemloft.net> <m3fyghz2oz.fsf@defiant.localdomain> <20060731.181314.27783697.davem@davemloft.net> <m3bqr5z0ah.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:9430 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1750727AbWHATzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 15:55:05 -0400
To: Krzysztof Halasa <khc@pm.waw.pl>
Content-Disposition: inline
In-Reply-To: <m3bqr5z0ah.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> > Alexey, any suggestions on how to handle this kind of thing?

Device, which adds something at head must check for space.
Anyone, who adds something at head, must check.
Otherwise, it will remain buggy forever.


> What's wrong with my patch?

As I already said there is nothing wrong with the first chunk.
Except that it hides the real problem.


> hardly their author's fault. I don't think we've ever advertised
> "hard_header_len is valid only with non-NULL hard_header".

Do not get it wrong. dev->hard_header_len is _NEVER_ guaranteed.
The places, which allocate skb, take it as a hint to avoid reallocation.
But each place which stuffs something at head, still must check the space.

The only difference between the situation with dev->hard_header,
is that when dev->hard_header != NULL, the header is added by IP itself.
That's why IP checks it.

Alexey
