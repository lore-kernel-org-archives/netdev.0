From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv4: Use standard iovec primitive in raw_probe_proto_opt
Date: Thu, 6 Nov 2014 14:46:29 +0800
Message-ID: <20141106064629.GA29321@gondor.apana.org.au>
References: <20141105035536.GO7996@ZenIV.linux.org.uk>
 <20141105.155054.2198151263164321219.davem@davemloft.net>
 <20141105210745.GT7996@ZenIV.linux.org.uk>
 <20141105.165719.835728206041332333.davem@davemloft.net>
 <20141106032533.GU7996@ZenIV.linux.org.uk>
 <20141106055023.GA28865@gondor.apana.org.au>
 <20141106064318.GW7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:41995 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbaKFGqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 01:46:38 -0500
Content-Disposition: inline
In-Reply-To: <20141106064318.GW7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 06, 2014 at 06:43:18AM +0000, Al Viro wrote:
> On Thu, Nov 06, 2014 at 01:50:23PM +0800, Herbert Xu wrote:
> > +	/* We only need the first two bytes. */
> > +	err = memcpy_fromiovecend((void *)&icmph, msg->msg_iov, 0, 2);
> > +	if (err)
> > +		return err;
> > +
> > +	fl4->fl4_icmp_type = icmph.type;
> > +	fl4->fl4_icmp_code = icmph.code;
> 
> That's more readable, but that exposes another problem in there - we read
> the same piece of userland data twice, with no promise whatsoever that we'll
> get the same value both times...

Sure, but you have to be root anyway to write to raw sockets.

Patches are welcome :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
