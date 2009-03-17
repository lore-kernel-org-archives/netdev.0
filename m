From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch 0/6] netfilter: ctnetlink allocation improvement
Date: Tue, 17 Mar 2009 10:49:00 +0100
Message-ID: <49BF720C.2010603@netfilter.org>
References: <20090316220659.756862181@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Holger Eitzenberger <holger@eitzenberger.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35812 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752249AbZCQJtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 05:49:09 -0400
In-Reply-To: <20090316220659.756862181@jonathan.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Holger,

Holger Eitzenberger wrote:
> what follows is a small patchset against net-next-2.6 which tries to
> improve the way ctnetlink events are allocated.  By allocating the
> ctnetlink skbs roughly the size of the message we prevent the skb from
> later being reallocated in netlink_trim().

I have a similar patch here that I sent time ago, I'll send it again, I
think that we can merge your patches and mine.

> Though I haven't got any hard performance numbers yet I think this
> might introduce a noticable performance gain.

I'm not sure about this. Instead, I noticed with oprofile that we spend
more cycles to calculate the message size. I think it's more like a
trade-off, reducing the message size to what we need reduces the chances
to hit ENOBUFS.

> I also have to introduce NF_CT_HELPER_NAME_LEN as an upper limit for
> the conntrack protcol helper names, which is not much of a problem
> because all names in mainline are actually shorter than that.

I'm fine with the helper size change. Actually the current size of 30
bytes doesn't make too much sense.

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
