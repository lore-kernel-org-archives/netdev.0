From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [CRYPTO] Fix stack overrun in crypt()
Date: Sat, 17 Jul 2004 17:43:19 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040717074319.GA18919@gondor.apana.org.au>
References: <20040715114840.GA1325@gondor.apana.org.au> <Pine.LNX.4.58.0407161126350.13406@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0407161126350.13406@devserv.devel.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 16, 2004 at 11:27:36AM -0400, James Morris wrote:
>
> > This fixes a number of weird crashes including those AES crashes
> > that people have been seeing with the 2.4 backport + ipt_conntrack.
> 
> Ok, thanks, looks good.

Thanks for reviewing it.

Unfortunately it looks like we still have a problem. gcc 3.3.4 appears
to be generating incorrect output on i386 with the dynamic stack
allocation used in crypt() and the functions around it.

In particular, it can give you 8 bytes when you ask for 16 bytes.
See my report at http://bugs.debian.org/259887 for details.

Fortunately, it seems that overwriting 8 bytes beyond the end of
the array in crypt() is not fatal.  After all, that's why people
only saw crashes with AES and not 3DES.

But this is still a potential source of problem, especially given
algorithms with bigger block sizes.

I think we should stop people from building the kernel with gcc 3.3.*
until this problem is addressed.  What do you guys think?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
