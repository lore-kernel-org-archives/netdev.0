From: kuznet@ms2.inr.ac.ru
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Wed, 15 Jan 2003 00:16:43 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301142116.AAA13616@sex.inr.ac.ru>
References: <Pine.LNX.4.33.0301140946230.1978-100000@dyn9-47-18-86.beaverton.ibm.com>
Mime-Version: 1.0
Cc: sri@us.ibm.com, jgrimm2@us.ibm.com, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sri@us.ibm.com (Sridhar Samudrala)
In-Reply-To: <Pine.LNX.4.33.0301140946230.1978-100000@dyn9-47-18-86.beaverton.ibm.com> from "Sridhar Samudrala" at Jan 14, 3 10:44:54 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> So can i go ahead and add an argument(ipfragok) to ip_queue_xmit()?

Positive.


> > Essentially, to make a compromise between usability and sanity,
> > it is enough to make the thing which we make with UDP: to prevent
> > sending bogus fragmented packets when IP_MTUDISC_DO is set by user
> > and set chunk size to a value < min(512,current mtu) in this case,
> > so no fragments will be generated. In that case I will be happy
> > (done all that possible, all the flaws are directed to SCTP designers. :-))
> > and default behaviour (it is IP_MTUDISC_WANT) still will be rfc compliant.
> 
> You seem to be suggesting
...

Nope. Reread the paragraph and look how UDP in IP_MTUDISC_DO mode works.
(The case of IPv6 is especially intersting) Adding similar mode to SCTP
is necessary to my opinion. Despite of the fact that nobody will use
the option, it is the only sane one.


> Also SCTP uses control chunks(INIT_ACK, COOKIE_ECHO) for association setup
> which can be larger than pmtu(although rare). The control chunks cannot be 
> fragmented by SCTP, but it is perfectly OK for IP to fragment them.

:-) Funnier and funnier. Oh, god...


> is no DF bit, it will automatically fragment any packets

Strange expectation. :-) TCP does not make this even in IPv4,
when pmtu discovery enabled.

SCTP is really born crippled. Face it. And be ready to breed an invalid. :-)


> available interface like ip6_build_xmit() when we want ip to fragment. 

Do not worry. We have to do this in ip6_xmit() for ipsec in any case.

Alexey
