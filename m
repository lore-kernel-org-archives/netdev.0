From: David Miller <davem@davemloft.net>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Mon, 26 Jan 2009 21:52:06 -0800 (PST)
Message-ID: <20090126.215206.223818647.davem@davemloft.net>
References: <4979097B.4040108@cs.wisc.edu>
	<20090125.213222.192571170.davem@davemloft.net>
	<20090126223022.GA24046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michaelc@cs.wisc.edu, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, olaf.kirch@oracle.com, tgraf@suug.ch,
	kkeil@suse.de
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41083
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752028AbZA0FwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 00:52:09 -0500
In-Reply-To: <20090126223022.GA24046@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 27 Jan 2009 09:30:22 +1100

> net: Fix frag_list handling in skb_seq_read
> 
> The frag_list handling was broken in skb_seq_read:
> 
> 1) We didn't add the stepped offset when looking at the head
> are of fragments other than the first.
> 
> 2) We didn't take the stepped offset away when setting the data
> pointer in the head area.
> 
> 3) The frag index wasn't reset.
> 
> This patch fixes both issues.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I see, the code is only clearing the fragment index when it's
advancing from one SKB to the next while already in the middle of a
->frag_list, not when transitioning past the root skb in such a list.

I bet some weird cases happen when "consumed" it's advanced by
the caller the entire length of data returned by the previous
skb_seq_read().

It all seems to be designed to work for that case, however.

Anyways, Herbert's patch looks definitely correct but until
we've gotten these crashes and hangs solved I don't want
to apply it.
