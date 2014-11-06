From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: ipv4: Use standard iovec primitive in raw_probe_proto_opt
Date: Thu, 6 Nov 2014 07:11:09 +0000
Message-ID: <20141106071109.GX7996@ZenIV.linux.org.uk>
References: <20141105035536.GO7996@ZenIV.linux.org.uk>
 <20141105.155054.2198151263164321219.davem@davemloft.net>
 <20141105210745.GT7996@ZenIV.linux.org.uk>
 <20141105.165719.835728206041332333.davem@davemloft.net>
 <20141106032533.GU7996@ZenIV.linux.org.uk>
 <20141106055023.GA28865@gondor.apana.org.au>
 <20141106064318.GW7996@ZenIV.linux.org.uk>
 <20141106064629.GA29321@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45491 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbaKFHLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 02:11:12 -0500
Content-Disposition: inline
In-Reply-To: <20141106064629.GA29321@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 06, 2014 at 02:46:29PM +0800, Herbert Xu wrote:
> On Thu, Nov 06, 2014 at 06:43:18AM +0000, Al Viro wrote:
> > On Thu, Nov 06, 2014 at 01:50:23PM +0800, Herbert Xu wrote:
> > > +	/* We only need the first two bytes. */
> > > +	err = memcpy_fromiovecend((void *)&icmph, msg->msg_iov, 0, 2);
> > > +	if (err)
> > > +		return err;
> > > +
> > > +	fl4->fl4_icmp_type = icmph.type;
> > > +	fl4->fl4_icmp_code = icmph.code;
> > 
> > That's more readable, but that exposes another problem in there - we read
> > the same piece of userland data twice, with no promise whatsoever that we'll
> > get the same value both times...
> 
> Sure, but you have to be root anyway to write to raw sockets.

Point, but that might very well be a pattern to watch for - there's at least
one more instance in TIPC (also not exploitable, according to TIPC folks)
and such bugs are easily repeated...

BTW, I've picked the tun and macvtap related bits from another part of old
queue; see vfs.git#untested-macvtap - it's on top of #iov_iter-net and it's
really completely untested.  Back then I was mostly interested in killing
as many ->aio_write() instances as I could, so it's only the "send" side of
things.
