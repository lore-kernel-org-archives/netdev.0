From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPsec xfrm resolution
Date: Sat, 19 Feb 2005 21:26:02 +0100
Message-ID: <4217A0DA.7050409@trash.net>
References: <20050210202810.GA1609@gondor.apana.org.au> <42144C3F.2060501@trash.net> <20050217091137.GA9476@gondor.apana.org.au> <42152841.5000707@trash.net> <20050218100854.GA19427@gondor.apana.org.au> <4216D6B4.5070901@trash.net> <20050219092314.GA8153@gondor.apana.org.au> <42173125.3040505@trash.net> <20050219183202.GA10773@gondor.apana.org.au> <421789AF.4020705@trash.net> <20050219190333.GA22166@gondor.apana.org.au> <4217993D.4070107@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010607080902030008090807"
Cc: Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <4217993D.4070107@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010607080902030008090807
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:

> I've checked KAME, it also skips IPSEC_LEVEL_USE SAs if they aren't 
> present.
> IPCOMP in tunnel mode is a special case. It wants to express more than 
> just
> "optional". It means to say "use SA if present and some things wrt. 
> size apply,
> otherwise use a similar SA with proto=IPIP". One of both has to be 
> used, and
> this is what "optional" can't express. The current method is to use 
> the IPIP
> SA automatically created with the IPCOMP SA when the compressed size 
> exceeds
> the uncompressed size, but it doesn't handle a missing SA. This 
> suggests we
> need to special-case tunnel mode IPCOMP in xfrm_tmpl_resolve() and either
> ignore "optional" for IPIP tunnel mode SAs or create them on demand.

How about this patch ? It ignores "optional" for missing tunnel mode 
SAs, symetric
to input.

Regards
Patrick


--------------010607080902030008090807
Content-Type: text/plain;
 name="x1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x1"

===== net/xfrm/xfrm_policy.c 1.66 vs edited =====
--- 1.66/net/xfrm/xfrm_policy.c	2005-02-16 00:16:04 +01:00
+++ edited/net/xfrm/xfrm_policy.c	2005-02-19 21:12:38 +01:00
@@ -656,7 +656,7 @@
 			xfrm_state_put(x);
 		}
 
-		if (!tmpl->optional)
+		if (!tmpl->optional || tmpl->mode)
 			goto fail;
 	}
 	return nx;

--------------010607080902030008090807--
