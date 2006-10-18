From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flow)
Date: Wed, 18 Oct 2006 09:20:02 +0100
Message-ID: <20061018082002.GA21120@fogou.chygwyn.com>
References: <4535B6B7.4070107@cosmosbay.com> <20061017.222709.130237201.davem@davemloft.net> <4535BEB9.3010400@cosmosbay.com> <20061017.235336.30182405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:63665 "EHLO fogou.chygwyn.com")
	by vger.kernel.org with ESMTP id S932098AbWJRI0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 04:26:16 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061017.235336.30182405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Oct 17, 2006 at 11:53:36PM -0700, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 18 Oct 2006 07:42:17 +0200
> 
> > How many people are using DECNET and want to pay the price of this
> > 20 bytes dnports structure ?
> 
Point taken :-) Eric, you also need to add a || defined(CONFIG_DECNET_MODULE)
I think in your patch, if you want to make this optional.

> I bet you could make that cost get hidden by careful rearrangement
> of the struct flow, or adjustment of the implementation.
> 
> BTW, I see assignments to these fields, and as a specific example
> uli_u.dnports.objnamel but no use of it.  Perhaps much of dnports can
> even be deleted outright. :-)
> -

Its not used at the moment[*], but would be required for any kind of flow
tracking. The objnum field, could be folded into the objname field I
guess on the basis that objnamel == 0 means objname[0] represents the objnum,
but that doesn't really buy much.

Looking at the rearrangement option, and the relative lengths of
ipv6 and DECnet node addresses, dn_u is a lot smaller than ip6_u and thus
the obj[num|name|namel] fields could be moved into that structure.
Even after doing this, dn_u would still be shorter than ip6_u, although
12 bytes longer than ip4_u (if my counting is correct). Is that an
acceptable solution?

[*] By which I mean, as you've already alluded to, that its set up correctly
but not currently read/tested by anything yet.

Steve.

