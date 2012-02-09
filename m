From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [v8 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Thu, 9 Feb 2012 19:32:03 +0100
Message-ID: <201202091932.03785.hans@schillstrom.com>
References: <1327675303-9059-1-git-send-email-hans.schillstrom@ericsson.com> <1327675303-9059-3-git-send-email-hans.schillstrom@ericsson.com> <20120208002743.GA29189@1984>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, kaber@trash.net,
	jengelh@medozas.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw11.han.skanova.net ([81.236.55.20]:33597 "EHLO
	smtp-gw11.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559Ab2BIScI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 13:32:08 -0500
In-Reply-To: <20120208002743.GA29189@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday, February 08, 2012 01:27:43 Pablo Neira Ayuso wrote:
> On Fri, Jan 27, 2012 at 03:41:42PM +0100, Hans Schillstrom wrote:
[snip]

> > +#if defined(CONFIG_NF_NAT)
> > +	if (ct && test_bit(IP_CT_IS_REPLY, &ct->status)) {
> > +		struct nf_conntrack_tuple *otuple;
> > +
> > +		otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
> > +		/*
> > +		 * On the "return flow", to get the original address
> > +		 */
> > +		if ((ct->status & IPS_DST_NAT) &&
> > +			(info->flags & XT_HMARK_USE_DNAT)) {
> > +			addr1 = (__force u32) otuple->dst.u3.in.s_addr;
> > +			dnatport = otuple->dst.u.udp.port;
> > +		}
> > +		if ((ct->status & IPS_SRC_NAT) &&
> > +			(info->flags & XT_HMARK_USE_SNAT)) {
> > +			addr2 = (__force u32) otuple->src.u3.in.s_addr;
> > +			snatport = otuple->src.u.udp.port;
> > +		}
> 
> You can make this much more simple.
> 
> Allow the user to tell your HMARK target to use the conntrack
> information instead.
> 
> My opinion is that the user must have total control on the target
> behaviour through the configuration options. The number of internal
> by-default decisions have to be kept up to the minimum, otherwise
> the behaviour of the target may seem obscure.
> 
> > +	}
> > +#endif
> > +	/* user space tool ensures that prmask is zero when method is L3*/

While dealing with fragmentation in ipvs, an idea run into my head...
why not take care of fragments from nfct_reasm in L3_4 mode ?

OK it might be an obscure behaviour but on the other hand
people expect that fragments is handled by netfilter...


/Hans
