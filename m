From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Sat, 17 Jan 2009 16:08:39 +1100
Message-ID: <20090117050839.GA24215@gondor.apana.org.au>
References: <20090115235803.GA9000@gondor.apana.org.au> <49704015.6020503@chelsio.com> <20090116085645.GA14678@gondor.apana.org.au> <49706B87.7080806@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42943 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750886AbZAQFIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 00:08:48 -0500
Content-Disposition: inline
In-Reply-To: <49706B87.7080806@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Divy:

On Fri, Jan 16, 2009 at 03:12:07AM -0800, Divy Le Ray wrote:
>
>        1.112500  __alloc_skb                         vmlinux

Can you confirm that you were testing 1500 byte packets?  If so
that would tell us why this function got up there.  As it stands
GRO will not stop aggregating even when the frags array is full,
until the skb size hits 64K.

That means half the packet will be in frag_list which is very
inefficient.

If this is indeed the problem, then for now I'll simply make
it stop aggregating after the array is full, just like LRO.

While in future we can extend it such that even when it starts
using frag_list, it'll still continue to fill in the frags array.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
