From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: xfrm_input() and ->seq oddities
Date: Sun, 3 Feb 2008 00:37:19 +0000
Message-ID: <20080203003718.GQ27894@ZenIV.linux.org.uk>
References: <20080202211635.GF9375@cs181133002.pp.htv.fi> <20080202222226.GB31388@gondor.apana.org.au> <20080202235827.GP27894@ZenIV.linux.org.uk> <20080203002019.GA32295@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33810 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbYBCAhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 19:37:22 -0500
Content-Disposition: inline
In-Reply-To: <20080203002019.GA32295@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 03, 2008 at 11:20:19AM +1100, Herbert Xu wrote:
> Al Viro spotted a bogus use of u64 on the input sequence number which
> is big-endian.  This patch fixes it by giving the input sequence number
> its own member in the xfrm_skb_cb structure.

This is still very odd...  Where do you initialize ->seq.input?  What
guarantees that async call of xfrm_input() will be always preceded by
at least one non-async one?
