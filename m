From: Patrick McHardy <kaber@trash.net>
Subject: Re: resend patch:  xfrm policybyid
Date: Mon, 09 May 2005 13:45:20 +0200
Message-ID: <427F4D50.4060702@trash.net>
References: <20050505213239.GA29526@gondor.apana.org.au>	 <1115331436.8006.112.camel@localhost.localdomain>	 <20050505231210.GA30574@gondor.apana.org.au>	 <1115342122.7660.25.camel@localhost.localdomain>	 <20050506013125.GA31780@gondor.apana.org.au>	 <1115345403.7660.49.camel@localhost.localdomain>	 <20050506085404.GA26719@gondor.apana.org.au>	 <1115380381.7660.123.camel@localhost.localdomain>	 <20050507105500.GA20283@gondor.apana.org.au>	 <1115469496.19561.41.camel@localhost.localdomain>	 <20050508080730.GA30512@gondor.apana.org.au>	 <1115562643.19561.148.camel@localhost.localdomain>	 <427E2F0D.4040902@trash.net> <1115573038.19561.174.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1115573038.19561.174.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> I can see where the %8 >= 3 comes from.
> [per socket creation with calls xfrm_gen_index(XFRM_POLICY_MAX+dir)
> and the kernel does things in increments of 8]
> 
> I didnt quiet understand that check in racoon: Why this guess work? if
> per-socket policies need to be identified, why dont they get explicitly
> marked as per-socket somehow? I am actually curious why that check is
> needed. Sorry have never stared at the racoon code. Do other IKE/ISAKMP
> daemons depend on it?

Not sure why they're not marked as per-socket. Probably because
sadb_x_policy_id is a KAME extension and KAME pf_key doesn't dump
these policies with SADB_X_SPDDUMP. Racoon needs to skip them
to avoid adding them to its internal SPD, they could conflict
with global policies.

>>So how could we handle this?
>>
> We can disallow the explicit setting of any index which passes test
> (index % 8 >= 3) - but it does seem to me the whole concept of reserving
> those indices for per-socket policies is a bit of a hack and may need a
> rethinking. Maybe we need to maintain a mark in the kernel for
> per-socket polices and do the same as BSD?

Disallowing this special case seems a bit inconsistent to me. We can
deduce which are per-socket from the list they are contained in. We
don't notify on per-socket policy change, perhaps we should also skip
them when dumping in pf_key.

Regards
Patrick
