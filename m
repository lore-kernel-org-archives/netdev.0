From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport mode with esp and ah hangs (problem is in xfrm_state_add)
Date: Mon, 31 Jan 2005 21:54:33 +1100
Message-ID: <E1CvZCT-00017g-00@gondolin.me.apana.org.au>
References: <20050130224404.5f78d28a.akpm@osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton), au@unterluggauer.org
In-Reply-To: <20050130224404.5f78d28a.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>  
> the SAD entries for ah and esp have the same km.seq!   

Sounds like a racoon bug.  The kernel will assign different
sequence numbers to the two SAs.  It will also send SADB_ACQUIRE
messages to racoon with those sequence numbers.  So if racoon is
sending two SADB_ADD commands with the same sequence number back
then it's broken.

Could you get a dump of the messages that racoon has received
and sent? That should tell us exactly what's happening.
  
> Workaround:  
> I comment the if (x->km.seq) { ... } out. than it works vor me. but I know  
> thats not a solution. 

Well without the check we would have silently ignored the sequence
number which is why you wouldn't have noticed the problem with racoon
before.

However, for those who need to use the sequence number this check is
necessary.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
