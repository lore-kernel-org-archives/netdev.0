From: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Subject: Re: IPsec and Path MTU
Date: Wed, 16 Jun 2004 10:43:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <28318.1087396999@marajade.sandelman.ottawa.on.ca>
References: <20040615124334.GA25164@gondor.apana.org.au> <32703.1087311037@marajade.sandelman.ottawa.on.ca>  <20040616114345.GA1559@gondor.apana.org.au>
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: Message from Herbert Xu <herbert@gondor.apana.org.au>
   of "Wed, 16 Jun 2004 21:43:45 +1000." <20040616114345.GA1559@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----


>>>>> "Herbert" == Herbert Xu <herbert@gondor.apana.org.au> writes:
    >> The pmtu WG is considering changing how PMTU is done. You may
    >> want to look at draft-richardson-ipsec-fragment-XX.txt. This has
    >> not yet been adopted as a WG draft, because nobody is sure which
    >> WG should adopt it:-)

    Herbert> I'd say that we should get the stack to work with the hosts
    Herbert> that do send ICMP replies first, and then worry about those
    Herbert> that don't :) 

  The proposal there is a compromise between what RFC1191 says, and what
people in the field (and most IPsec implementations, because we get
blamed) have done - it continues to send ICMP replies at all times that
the old logic would usefully do, while not causing huge headaches that
having ICMPs disappear causes. 

  My opinion is that any solution which does not address the problem of
ICMP blackholes is actually a step back because it causes things to
intermittently fail. Right now, things just fail for big packets,
period. That provides much large clue that there is a problem, which can
be worked around. 

  So, I'm agreeing with your :) -- we can tune the algorithm later, but
let's make sure that we do it ASAP.

- --
]     "Elmo went to the wrong fundraiser" - The Simpson         |  firewalls  [
]   Michael Richardson,    Xelerance Corporation, Ottawa, ON    |net architect[
] mcr@xelerance.com      http://www.sandelman.ottawa.on.ca/mcr/ |device driver[
] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Finger me for keys

iQCVAwUBQNBchIqHRg3pndX9AQFQWwQApGSYmkgs/4nogHYipee21MEannapT54m
sAle7/fBIxUqIKZev8/RlrnVI+n8+e//AQBooeRF1ubmrd0LfajVd1TwwKvdE40S
47ysQrgSm3BHGet1xn+QLxYc3l9WumP7Ey+EkUKi22azcnjEvJ35r5crkMy2kVcg
nALPB7hDwj0=
=+nu7
-----END PGP SIGNATURE-----
