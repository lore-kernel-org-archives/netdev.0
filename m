From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Wed, 2 Aug 2006 00:25:03 +0400
Message-ID: <20060801202503.GA30889@ms2.inr.ac.ru>
References: <m3zmevqhgn.fsf@defiant.localdomain> <20060727164334.GA2779@ms2.inr.ac.ru> <m3fygjkpwb.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:63449 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1161036AbWHAUZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 16:25:04 -0400
To: Krzysztof Halasa <khc@pm.waw.pl>
Content-Disposition: inline
In-Reply-To: <m3fygjkpwb.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Do the semantics (I'm not talking about bugs) allow skb passed
> to dev->hard_header() (if defined)

No. dev->hard_header() should get enough of space, which is
dev->hard_header_len.

Actually, it is historical hole in design, inherited from ancient
times. Calling conventions of dev->hard_header() just did not allow
to reallocate. BTW in 2.6 it can, if it uses pskb_expand_head().


>			 and then to dev->hard_start_xmit()
> to have less link layer header space than dev->hard_header_len?

Absolutely. It used to happen all the time. All those devices,
which occasionally forget to check for space must be fixed.


> I.e., is dev->hard_header_len only advisory?

For initial allocator it is an advice. For layers, which add something
at head, it is just nothing, if there is enough space. And it is again
an advice, when skb is reallocated.


> Anyway, the issue with kernel panic is real so I think we better
> fix it before 2.6.18, and propagate to "stable" series as well.

:-) Know what? This problem followed us since prehistoric times.
It happened in 2.4-stablest, 2.2-stable, 2.0... The same devices,
the same problem, no matter how much of space it is given to them,
they managed to find a hole and to crash. :-)

Alexey
