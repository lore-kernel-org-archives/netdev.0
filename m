From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Thu, 17 Jul 2003 10:04:33 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307170956440.1348-100000@netcore.fi>
References: <200307170020.EAA12924@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <jmorris@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307170020.EAA12924@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jul 2003 kuznet@ms2.inr.ac.ru wrote:
> > Yes, I dare to say that they're a requirement. 
> 
> Nope. IPv6 host routing is based on assumption of link-locality of the
> next hop. Probably, you want to read some rfcs or to look into code.

This is not correct.  Perhaps the RFC's have changed in the meantime, but 
at least RFC2461 does *not* make such an assumption (AFAICS).

In the document, there is a basic assumption that the next-hop is
*on-link*.

In the document, there are assumptions on verifying whether the redirects
come from the router you're currently using: this is simpler when you 
use only link-locals as next-hops, but it is certainly *NOT* a 
requirement.

(The spec in question will be revised in the short term, so I'll take this
issue up for clarification..)

> > specifications use and the *users* want and need to use.
> 
> Sigh, there no specifications about tricks used by Linux routing tables,
> *users* are unlikely to want to use this feature at all, as Mika noticed.
> And when they want, they want to right:
> 
>     ip route add 3ffe::.... via 193.233.7.65

That would be simpler but, we actually require:

ip route add 3ffe::... via ::193.233.7.65

and thus require a route for ::/96.  That's confusing: ::/96 has a very 
specific purpose in RFCs, and we should not be overloading the 
functionality, it's just plain confusing.
 
> rather than crap sort of
>
>     ip route add 3ffe::.... via 2002:<something in latin>

I'm not saying we need to prevent the users from using the former.  I'm 
just saying that we must not prevent the users from using the latter; 
please check e.g. the RFC3068 section 2.5.  If we don't support something 
like that, it'll just confuse the users more.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
