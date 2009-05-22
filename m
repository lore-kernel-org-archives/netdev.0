From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC 2/2] net: Allow protocols to provide an unlocked_recvmsg
	sk_prot method
Date: Fri, 22 May 2009 11:52:15 -0300
Message-ID: <20090522145215.GR5956@ghostprotocols.net>
References: <20090520230659.GC5956@ghostprotocols.net> <200905221026.51789.remi.denis-courmont@nokia.com> <20090522.004738.139438566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org,
	vanhoof@redhat.com, williams@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47265 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753513AbZEVOwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2009 10:52:25 -0400
Content-Disposition: inline
In-Reply-To: <20090522.004738.139438566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, May 22, 2009 at 12:47:38AM -0700, David Miller escreveu:
> From: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
> Date: Fri, 22 May 2009 10:26:51 +0300
>=20
> > On Thursday 21 May 2009 02:06:59 ext Arnaldo Carvalho de Melo wrote=
:
> >> @@ -265,6 +265,9 @@ struct ucred {
> >>  #define MSG_ERRQUEUE	0x2000	/* Fetch message from error queue */
> >>  #define MSG_NOSIGNAL	0x4000	/* Do not generate SIGPIPE */
> >>  #define MSG_MORE	0x8000	/* Sender will send more */
> >> +#ifdef __KERNEL__
> >> +#define MSG_UNLOCKED	0x10000	/* Don't lock the sock */
> >> +#endif
> >=20
> > I might be missing something but... What prevents an evil userland =
from=20
> > setting the flag anyway and hitting the BUG case?
>=20
> Yes, we'll need to clear this on all paths where we get msg
> flags from the user.
>=20
> There's a lot of such places.
>=20
> So maybe we need to pass this state around in a different,
> internal, way.

Yeah, I'll think about it, that was the easiest way to implement it for
the proof of concept we have now. Filtering it out at syscall entry and
at sock_common_recvmsg would fix it, but I'm not sure if its the best
option.

The comments about the interface provided to userspace (struct mmsghdr)=
,
how to return errors after some datagrams were put in the array
(sk->sk_err being stored then returned in the next call), timeouts, etc
are great, thanks, after some more comments I'll respin these patches.

- Arnaldo
