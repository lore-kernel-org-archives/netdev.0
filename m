From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: gro: Make GRO aware of lightweight tunnels.
Date: Mon, 8 Feb 2016 19:49:56 -0500
Message-ID: <20160209004956.GA18196@codemonkey.org.uk>
References: <20160202022858.60C826612C0@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:36820 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912AbcBIAuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 19:50:00 -0500
Content-Disposition: inline
In-Reply-To: <20160202022858.60C826612C0@gitolite.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 02, 2016 at 02:28:58AM +0000, Linux Kernel wrote:
 > Web:        https://git.kernel.org/torvalds/c/ce87fc6ce3f9f4488546187e3757cf666d9d4a2a
 > Commit:     ce87fc6ce3f9f4488546187e3757cf666d9d4a2a
 > Parent:     5f2f3cad8b878b23f17a11dd5af4f4a2cc41c797
 > Refname:    refs/heads/master
 > Author:     Jesse Gross <jesse@kernel.org>
 > AuthorDate: Wed Jan 20 17:59:49 2016 -0800
 > Committer:  David S. Miller <davem@davemloft.net>
 > CommitDate: Wed Jan 20 18:48:38 2016 -0800
 > 
 >     gro: Make GRO aware of lightweight tunnels.

Coverity just started complaining about this commit.

 > diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
 > index 6816f0f..30a56ab 100644
 > --- a/include/net/dst_metadata.h
 > +++ b/include/net/dst_metadata.h
 > @@ -44,6 +44,24 @@ static inline bool skb_valid_dst(const struct sk_buff *skb)
 >  	return dst && !(dst->flags & DST_METADATA);
 >  }
 >  
 > +static inline int skb_metadata_dst_cmp(const struct sk_buff *skb_a,
 > +				       const struct sk_buff *skb_b)
 > +{
 > +	const struct metadata_dst *a, *b;
 > +
 > +	if (!(skb_a->_skb_refdst | skb_b->_skb_refdst))
 > +		return 0;
 > +
 > +	a = (const struct metadata_dst *) skb_dst(skb_a);
 > +	b = (const struct metadata_dst *) skb_dst(skb_b);
 > +
 > +	if (!a != !b || a->u.tun_info.options_len != b->u.tun_info.options_len)

It complains that we could dereference a null 'a' here.

It's possible the checker got confused, but the first part of that
expression looks odd, is that doing what's intended ?

	Dave
