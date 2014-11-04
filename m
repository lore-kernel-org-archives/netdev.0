From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Tue, 4 Nov 2014 22:42:58 +0800
Message-ID: <20141104144258.GA14743@gondor.apana.org.au>
References: <20141104033818.GA11149@gondor.apana.org.au>
 <E1XlZWY-0003HZ-Ef@gondolin.me.apana.org.au>
 <20141104143200.GC7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51526 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbaKDOnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 09:43:08 -0500
Content-Disposition: inline
In-Reply-To: <20141104143200.GC7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 04, 2014 at 02:32:00PM +0000, Al Viro wrote:
>
> Too noisy, IMO.  How about skb_copy_datagram_msg() first?  The fewer
> places have to even think of iovec or iov_iter, the better...

We have places like tcp ucopy and tun that do not have msghdr.
So doing skb_copy_datagram_msg means that we'd have to create
a fake msghdr wrapper around them.  The point is not everything
comes in via sendmsg/recvmsg.

What is your motivation for hiding iov/iov_iter? Do you plan to
change their API at some future point?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
