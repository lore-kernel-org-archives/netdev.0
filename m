From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v3 12/18] crypto: switch af_alg_make_sg() to iov_iter
Date: Mon, 9 Feb 2015 17:28:11 +0000
Message-ID: <20150209172811.GZ29656@ZenIV.linux.org.uk>
References: <20150204063730.GG29656@ZenIV.linux.org.uk>
 <1423032009-18367-12-git-send-email-viro@ZenIV.linux.org.uk>
 <2856206.EMAskHcVAC@tachyon.chronox.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49258 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932308AbbBIR2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 12:28:14 -0500
Content-Disposition: inline
In-Reply-To: <2856206.EMAskHcVAC@tachyon.chronox.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 09, 2015 at 02:33:48PM +0100, Stephan Mueller wrote:
> > 
> > -int af_alg_make_sg(struct af_alg_sgl *sgl, void __user *addr, int len,
> > -		   int write)
> > +int af_alg_make_sg(struct af_alg_sgl *sgl, struct iov_iter *iter, int len)
> 
> Shouldn't len be size_t? iov_iter_get_pages wants a size_t. Also, the 
> invocation of af_alg_make_sg uses an unsigned variable that is provided by 
> userspace.

Keepo in mind that rw_copy_check_uvector() does, among other things,
verify that total length is less than 2^31.  So this code doesn't
suffer from wraparounds; it might make sense to switch to size_t here,
but that's a separate patch, IMO.  For this conversion I just kept
the type that used to be there.
