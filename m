From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Checking SPI in xfrm_state_find
Date: Tue, 29 Mar 2005 09:39:17 +1000
Message-ID: <20050328233917.GB15369@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <424864CE.5060802@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 28, 2005 at 10:10:54PM +0200, Patrick McHardy wrote:
> 
> Something unrelated I was also wondering about, from xfrm_find_state():
> 
>         list_for_each_entry(x, xfrm_state_bydst+h, bydst) {
>                 if (x->props.family == family &&
>                     x->props.reqid == tmpl->reqid &&
>                     xfrm_state_addr_check(x, daddr, saddr, family) &&
>                     tmpl->mode == x->props.mode &&
>                     tmpl->id.proto == x->id.proto) {
> 
> Shouldn't we check for (tmpl->id.spi == x->id.spi || !tmpl->id.spi) ?

Absolutely.  We should also fix the larval state generation in that
same function to fail the operation if that SPI already exists.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
