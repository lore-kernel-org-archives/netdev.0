From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Fri, 13 Aug 2010 16:48:07 +0200
Message-ID: <1281710887.4470.78.camel@edumazet-laptop>
References: <1279699529.3707.5.camel@jlt3.sipsolutions.net>
	 <1279700420.2452.15.camel@edumazet-laptop>
	 <1279701835.2452.17.camel@edumazet-laptop>
	 <20100725.215548.112589000.davem@davemloft.net>
	 <1281708024.3760.12.camel@jlt3.sipsolutions.net>
	 <1281710115.3760.27.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43723 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761714Ab0HMOsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 10:48:12 -0400
Received: by wwj40 with SMTP id 40so3038996wwj.1
        for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 07:48:11 -0700 (PDT)
In-Reply-To: <1281710115.3760.27.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 13 ao=C3=BBt 2010 =C3=A0 16:35 +0200, Johannes Berg a =C3=A9=
crit :
> On Fri, 2010-08-13 at 16:00 +0200, Johannes Berg wrote:
> > On Sun, 2010-07-25 at 21:55 -0700, David Miller wrote:
> > > From: Eric Dumazet <eric.dumazet@gmail.com>
> > > Date: Wed, 21 Jul 2010 10:43:55 +0200
> > >=20
> > > > [PATCH net-next-2.6 v3] netlink: netlink_recvmsg() fix
> > > >=20
> > > > commit 1dacc76d0014=20
> > > > (net/compat/wext: send different messages to compat tasks)
> > > > introduced a race condition on netlink, in case MSG_PEEK is use=
d.
> > > >=20
> > > > An skb given by skb_recv_datagram() might be shared, we must co=
py it
> > > > before any modification, or risk fatal corruption.
> > > >=20
> > > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > >=20
> > > Applied, thanks Eric.
> >=20
> > I keep getting errors like below in 2.6.35+wireless-testing. Not sa=
ying
> > that it's this patch's fault, but it is the only thing I remember
> > touching that area.
>=20
> In fact, I think something's wrong with this patch, since my comment
> (that right now unfortunately I no longer fully understand) says:
>=20
>                  * If this skb has a frag_list, then here that means =
that
>                  * we will have to use the frag_list skb for compat t=
asks
>                  * and the regular skb for non-compat tasks.
>                  *
>                  * The skb might (and likely will) be cloned, so we c=
an't
>                  * just reset frag_list and go on with things -- we n=
eed to
>                  * keep that. For the compat case that's easy -- simp=
ly get
>                  * a reference to the compat skb and free the regular=
 one
>                  * including the frag. For the non-compat case, we ne=
ed to
>                  * avoid sending the frag to the user -- so assign NU=
LL but
>                  * restore it below before freeing the skb.
>=20
> and that's no longer true, afaict.
>=20

Comment was not updated by the patch.

But do you agree temporarly setting frag_list to NULL was a bug ?

Unfortunatly I cannot test this path...

I assume reverting 1235f504aaba removes these errors ?


Its strange we have a double-free on a data part and not a skb_head.

maybe pskb_copy() has a problem with frag_list...


Maybe we can revert the patch and find another way to make sure two
process can not manipulate this skb in // (adding a mutex, or using
RTNL ?)



