From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Thu, 27 Jul 2006 20:43:34 +0400
Message-ID: <20060727164334.GA2779@ms2.inr.ac.ru>
References: <m3zmevqhgn.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:2263 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751738AbWG0Qnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 12:43:46 -0400
To: Krzysztof Halasa <khc@pm.waw.pl>
Content-Disposition: inline
In-Reply-To: <m3zmevqhgn.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> ip_output() ignores dev->hard_header_len

ip_output() worries about the space, which it needs.

If some place needs more, it is its problem to check.
To the moment where it is used, hard_header_len can even change.

It can be applied, but it does not change the fact, that those
placed which fail now must check the condition as well.


> A similar problem may be present in psched_mtu().

Nothing similar. The result psched_mtu() is compared with skb->len,
how it is seen by qdiscs. If hard_header is NULL, it sees skbs
without header.

Alexey
