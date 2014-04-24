From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 3/3] net: ipv6: Use ip6_datagram_send_common in ping.
Date: Thu, 24 Apr 2014 17:06:57 +0200
Message-ID: <20140424150657.GG1960@order.stressinduktion.org>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com> <1398235078-27088-1-git-send-email-lorenzo@google.com> <1398235078-27088-3-git-send-email-lorenzo@google.com> <53579FD8.2090309@enst-bretagne.fr> <CAKD1Yr1bYu1Rtqi6cfSTsnq14dj+esOd=MsPaUs-CbqkFY5H8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37046 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178AbaDXPG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 11:06:58 -0400
Content-Disposition: inline
In-Reply-To: <CAKD1Yr1bYu1Rtqi6cfSTsnq14dj+esOd=MsPaUs-CbqkFY5H8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 09:22:23PM +0900, Lorenzo Colitti wrote:
> On Wed, Apr 23, 2014 at 8:11 PM, Florent Fourcot
> <florent.fourcot@enst-bretagne.fr> wrote:
> > Le 22/04/2014 17:14, Lorenzo Colitti a =C3=A9crit :> +
> >> +             if (sin6->sin6_family !=3D AF_INET6)
> >> +                     return -EAFNOSUPPORT;
> >> +
> >
> > It has before returned -EINVAL, it changes the return to the user s=
pace.
> > You made it consistent with other protocols, but perhaps should you=
 add
> > a notice in the commit changelog?
>=20
> Actually I'm not sure what the correct value is. When you setsockopt
> IPV6_V6ONLY and then send to a mapped address, the error you get
> depends on what you're trying to do - ip6_datagram_connect returns
> EAFNOSUPPORT, but udpv6_sendmsg, dccp_v6_connect and tcp_v6_connect
> return ENETUNREACH. I think EINVAL is wrong. EAFNOSUPPORT is probably
> best because the code doesn't support dual-stack ping sockets, but it
> could.
>=20
> There are probably very few users of this code at the moment, since
> the code was only released in 3.12, and support hasn't made it into
> iputils yet. And even there, ping just probably prints the error
> message and exits. So I don't think it's a big deal to change the
> return code.

Sure, but we don't know about other applications. Wouldn't it be just e=
asier
and leave this as is for now and finally let ipv6 ping sockets also han=
dle
ipv4? I looked at it some time ago and it didn't look complicated.

> >> -             if (sk->sk_bound_dev_if &&
> >> -                 sk->sk_bound_dev_if !=3D u->sin6_scope_id) {
> >> -                     return -EINVAL;
> >> -             }
> >
> > What about this check now ?
>=20
> I think that was incorrect. It would return EINVAL even if you did
> something as simple as:
>=20
> - Open an IPv6 ping socket.
> - Bind it to eth0 with SO_BINDTODEVICE
> - Send a ping to 2001:: without specifying a scope id.

Agree with that.

Bye,

  Hannes
