From: jamal <hadi@cyberus.ca>
Subject: Re: resend patch:  xfrm policybyid
Date: Mon, 09 May 2005 09:10:29 -0400
Message-ID: <1115644229.19561.263.camel@localhost.localdomain>
References: <20050505213239.GA29526@gondor.apana.org.au>
	 <1115331436.8006.112.camel@localhost.localdomain>
	 <20050505231210.GA30574@gondor.apana.org.au>
	 <1115342122.7660.25.camel@localhost.localdomain>
	 <20050506013125.GA31780@gondor.apana.org.au>
	 <1115345403.7660.49.camel@localhost.localdomain>
	 <20050506085404.GA26719@gondor.apana.org.au>
	 <1115380381.7660.123.camel@localhost.localdomain>
	 <20050507105500.GA20283@gondor.apana.org.au>
	 <1115469496.19561.41.camel@localhost.localdomain>
	 <20050508080730.GA30512@gondor.apana.org.au>
	 <1115562643.19561.148.camel@localhost.localdomain>
	 <427E2F0D.4040902@trash.net>
	 <1115573038.19561.174.camel@localhost.localdomain>
	 <427F4D50.4060702@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427F4D50.4060702@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-09-05 at 13:45 +0200, Patrick McHardy wrote:

> Not sure why they're not marked as per-socket. Probably because
> sadb_x_policy_id is a KAME extension and KAME pf_key doesn't dump
> these policies with SADB_X_SPDDUMP. Racoon needs to skip them
> to avoid adding them to its internal SPD, they could conflict
> with global policies.
> 

But as you can see without having some KAME extension or explicit flag
it resorts to some hack. I have a feeling they may have to put a
different hack for each OS that is not BSD derived.

> >>So how could we handle this?
> >>
> > We can disallow the explicit setting of any index which passes test
> > (index % 8 >= 3) - but it does seem to me the whole concept of reserving
> > those indices for per-socket policies is a bit of a hack and may need a
> > rethinking. Maybe we need to maintain a mark in the kernel for
> > per-socket polices and do the same as BSD?
> 
> Disallowing this special case seems a bit inconsistent to me. 

Well, those indices are "reserved"  in a sense; so if we can get rid of
that speacial casing even better.

> We can
> deduce which are per-socket from the list they are contained in. We
> don't notify on per-socket policy change, perhaps we should also skip
> them when dumping in pf_key.

this sounds reasonable and would remove the necessity of special-casing
those indices. 

cheers,
jamal
