From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Thu, 9 Feb 2006 10:08:03 +1100
Message-ID: <20060208230803.GA26038@gondor.apana.org.au>
References: <E1F6xei-0006hc-00@gondolin.me.apana.org.au> <OF71FA79DA.C4F20DA5-ON8825710F.007B701A-8825710F.007CB97E@us.ibm.com> <20060208.144712.66821895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, adobriyan@gmail.com,
	carlsonj@workingcode.com, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	viro@ftp.linux.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060208.144712.66821895.davem@davemloft.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2006 at 02:47:12PM -0800, David S. Miller wrote:
> From: David Stevens <dlstevens@us.ibm.com>
> Date: Wed, 8 Feb 2006 14:45:08 -0800
> 
> >         Why would sparse complain about this? 0 is a well-defined
> > pointer value (the only value guaranteed to be by the language).
> 
> Because sparse goes beyond the standards and tries to
> catch cases that usually end up being bugs.

Well to be frank the only significant NULL/0 bug that I know can't
be caught by converting 0 to NULL anyway.  The bug only exists on
architectures where the representations of null-pointers of types
are different.  On those architectures, if you have something like

int func(char *fmt, ...);

...

	func("foo", NULL);

Then this may break if func actually expected a int * while NULL
could be something different altogether.  The only safe way to
write this is to have

	func("foo", (int *)NULL);

or

	func("foo", (int *)0);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
