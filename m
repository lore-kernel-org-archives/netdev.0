From: jamal <hadi@cyberus.ca>
Subject: Re: resend patch:  xfrm policybyid
Date: Sun, 08 May 2005 13:23:58 -0400
Message-ID: <1115573038.19561.174.camel@localhost.localdomain>
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
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427E2F0D.4040902@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-08-05 at 17:23 +0200, Patrick McHardy wrote:

> Allowing the user to freely set indices breaks racoon:
> 
> #ifdef __linux__
>         /* bsd skips over per-socket policies because there will be no
>          * src and dst extensions in spddump messages. On Linux the only
>          * way to achieve the same is check for policy id.
>          */
>         if (xpl->sadb_x_policy_id % 8 >= 3) return 0;
> #endif
> 

I can see where the %8 >= 3 comes from.
[per socket creation with calls xfrm_gen_index(XFRM_POLICY_MAX+dir)
and the kernel does things in increments of 8]

I didnt quiet understand that check in racoon: Why this guess work? if
per-socket policies need to be identified, why dont they get explicitly
marked as per-socket somehow? I am actually curious why that check is
needed. Sorry have never stared at the racoon code. Do other IKE/ISAKMP
daemons depend on it?

> So how could we handle this?
> 

We can disallow the explicit setting of any index which passes test
(index % 8 >= 3) - but it does seem to me the whole concept of reserving
those indices for per-socket policies is a bit of a hack and may need a
rethinking. Maybe we need to maintain a mark in the kernel for
per-socket polices and do the same as BSD?

cheers,
jamal
