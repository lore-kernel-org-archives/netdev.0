From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv4: Use standard iovec primitive in raw_probe_proto_opt
Date: Fri, 7 Nov 2014 10:00:25 +0800
Message-ID: <20141107020025.GC9101@gondor.apana.org.au>
References: <20141106055023.GA28865@gondor.apana.org.au>
 <20141106064318.GW7996@ZenIV.linux.org.uk>
 <20141106064629.GA29321@gondor.apana.org.au>
 <20141106.162808.1546139916210194279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org, nakam@linux-ipv6.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141106.162808.1546139916210194279.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 06, 2014 at 04:28:08PM -0500, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 6 Nov 2014 14:46:29 +0800
> 
> > On Thu, Nov 06, 2014 at 06:43:18AM +0000, Al Viro wrote:
> >> On Thu, Nov 06, 2014 at 01:50:23PM +0800, Herbert Xu wrote:
> >> > +	/* We only need the first two bytes. */
> >> > +	err = memcpy_fromiovecend((void *)&icmph, msg->msg_iov, 0, 2);
> >> > +	if (err)
> >> > +		return err;
> >> > +
> >> > +	fl4->fl4_icmp_type = icmph.type;
> >> > +	fl4->fl4_icmp_code = icmph.code;
> >> 
> >> That's more readable, but that exposes another problem in there - we read
> >> the same piece of userland data twice, with no promise whatsoever that we'll
> >> get the same value both times...
> > 
> > Sure, but you have to be root anyway to write to raw sockets.
> > 
> > Patches are welcome :)
> 
> I'd agree with this root-only argument maybe 15 years ago, but with
> containers and stuff like that we want to prevent root X from messing
> up the machine for root Y.
> 
> This is a recurring topic, and I'd strongly like to avoid adding new
> ways that these kinds of problems can happen.
> 
> For example, I'm still on the hook to address the AF_NETLINK mmap TX
> code, which has a similarly abusable issue.

Fair enough.  Even though the bug existed prior to my patch I'll
see if we could get rid of it.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
