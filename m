From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: ipv4: Use standard iovec primitive in raw_probe_proto_opt
Date: Thu, 6 Nov 2014 09:55:31 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C3087CA@eusaamb103.ericsson.se>
References: <20141105035536.GO7996@ZenIV.linux.org.uk>
 <20141105.155054.2198151263164321219.davem@davemloft.net>
 <20141105210745.GT7996@ZenIV.linux.org.uk>
 <20141105.165719.835728206041332333.davem@davemloft.net>
 <20141106032533.GU7996@ZenIV.linux.org.uk>
 <20141106055023.GA28865@gondor.apana.org.au>
 <20141106064318.GW7996@ZenIV.linux.org.uk>
 <20141106064629.GA29321@gondor.apana.org.au>
 <20141106071109.GX7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bcrl@kvack.org" <bcrl@kvack.org>,
	"Masahide Nakamura" <nakam@linux-ipv6.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg20.ericsson.net ([198.24.6.45]:53790 "EHLO
	usevmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbaKFJzd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 04:55:33 -0500
In-Reply-To: <20141106071109.GX7996@ZenIV.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Al Viro
> Sent: November-06-14 8:11 AM
> To: Herbert Xu
> Cc: David Miller; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> bcrl@kvack.org; Masahide Nakamura; Hideaki YOSHIFUJI
> Subject: Re: ipv4: Use standard iovec primitive in raw_probe_proto_opt
> 
> On Thu, Nov 06, 2014 at 02:46:29PM +0800, Herbert Xu wrote:
> > On Thu, Nov 06, 2014 at 06:43:18AM +0000, Al Viro wrote:
> > > On Thu, Nov 06, 2014 at 01:50:23PM +0800, Herbert Xu wrote:
> > > > +	/* We only need the first two bytes. */
> > > > +	err = memcpy_fromiovecend((void *)&icmph, msg->msg_iov, 0, 2);
> > > > +	if (err)
> > > > +		return err;
> > > > +
> > > > +	fl4->fl4_icmp_type = icmph.type;
> > > > +	fl4->fl4_icmp_code = icmph.code;
> > >
> > > That's more readable, but that exposes another problem in there - we
> > > read the same piece of userland data twice, with no promise
> > > whatsoever that we'll get the same value both times...
> >
> > Sure, but you have to be root anyway to write to raw sockets.
> 
> Point, but that might very well be a pattern to watch for - there's at least one
> more instance in TIPC (also not exploitable, according to TIPC folks) and such

I don't recall this, and I can't see where it would be either. Can you please
point to where it is?

///jon

> bugs are easily repeated...
> 
> BTW, I've picked the tun and macvtap related bits from another part of old
> queue; see vfs.git#untested-macvtap - it's on top of #iov_iter-net and it's
> really completely untested.  Back then I was mostly interested in killing as
> many ->aio_write() instances as I could, so it's only the "send" side of things.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
