From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC 4/5] tun: vringfd xmit support.
Date: Tue, 8 Apr 2008 11:51:43 +1000
Message-ID: <200804081151.43599.rusty@rustcorp.com.au>
References: <E1Jijfs-0004Lo-00@gondolin.me.apana.org.au> <200804071724.51781.rusty@rustcorp.com.au> <20080407.003528.96136816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	maxk@qualcomm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36579 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756615AbYDHCEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 22:04:21 -0400
In-Reply-To: <20080407.003528.96136816.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 07 April 2008 17:35:28 David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Mon, 7 Apr 2008 17:24:51 +1000
>
> > On Monday 07 April 2008 15:13:44 Herbert Xu wrote:
> > > On second thought, this is not going to work.  The network stack
> > > can clone individual pages out of this skb and put it into a new
> > > skb.  Therefore whatever scheme we come up with will either need
> > > to be page-based, or add a flag to tell the network stack that it
> > > can't clone those pages.
> >
> > Erk... I'll put in the latter for now.   A page-level solution is not
> > really an option: if userspace hands us mmaped pages for example.
>
> Keep in mind that the core of the TCP stack really depends
> upon being able to slice and dice paged SKBs as is pleases
> in order to send packets out.
>
> In fact, it also does such splitting during SACK processing.
>
> It really is a base requirement for efficient TSO support.
> Otherwise the above operations would be so incredibly
> expensive we might as well rip all of the TSO support out.

In this case that's OK; these are only for packets coming from 
userspace/guest, so the only interaction with the tcp code is possibly as a 
recipient.

If tcp wanted to do zero-copy aio xmit, I think we'd need something else.

Cheers,
Rusty.




