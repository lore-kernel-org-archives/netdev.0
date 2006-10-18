From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flow)
Date: Wed, 18 Oct 2006 13:42:02 +0100
Message-ID: <20061018124202.GA31981@fogou.chygwyn.com>
References: <4535B6B7.4070107@cosmosbay.com> <20061017.235336.30182405.davem@davemloft.net> <20061018082002.GA21120@fogou.chygwyn.com> <200610181055.32102.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:32999 "EHLO fogou.chygwyn.com")
	by vger.kernel.org with ESMTP id S1030196AbWJRMsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 08:48:19 -0400
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <200610181055.32102.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> >
> > Its not used at the moment[*], but would be required for any kind of flow
> > tracking. The objnum field, could be folded into the objname field I
> > guess on the basis that objnamel == 0 means objname[0] represents the
> > objnum, but that doesn't really buy much.
> 
> Well, as I privately said to David, objnamel is used, at least on 2.6.18 tree
> ( net/decnet/dn_route.c function compare_keys() 
> memcmp() will read this field and check before comparing objname[]
> 
> So it is set by dn_sk_ports_copy(), and used by compare_keys()
>
It is set by dn_sk_ports_copy() as you say, but the obj[num|name|namel]
fields are not used as a key in compare_keys() at the moment, although
all the other fields are used there.

Since the recent bug fix to this area of the code (memcmp was
comparing uninitialised padding) its easier to see what is
being compared.

In fact I suspect the reason that the obj fields were not put
in the dn_u where they'd take up a lot less room was
because the memcmp covered only dn_u and not the rest of the
structure. It was a while ago that I wrote this and my memory
is failing me as to the exact reason I did it like that.
 
> >
> > Looking at the rearrangement option, and the relative lengths of
> > ipv6 and DECnet node addresses, dn_u is a lot smaller than ip6_u and thus
> > the obj[num|name|namel] fields could be moved into that structure.
> > Even after doing this, dn_u would still be shorter than ip6_u, although
> > 12 bytes longer than ip4_u (if my counting is correct). Is that an
> > acceptable solution?
> 
> Well, most of my machines dont use IPV6 nor DECNET :)
> 
Its still an improvement over the current situation, even though
it might be (probably is) possible to improve it further,

Steve.

