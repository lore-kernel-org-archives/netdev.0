From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH] ipv4: Use netinet->inet_opt in inet_csk_route_child_sock()
Date: Mon, 20 Aug 2012 14:11:08 +0200
Message-ID: <5983241.9X7tkM4Yyi@cpaasch-mac>
References: <1345239312-19266-1-git-send-email-christoph.paasch@uclouvain.be> <20120820.025147.936465141809418575.davem@davemloft.net>
Reply-To: Christoph Paasch <christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:43227 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605Ab2HTMLO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 08:11:14 -0400
In-Reply-To: <20120820.025147.936465141809418575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 20 August 2012 02:51:47 David Miller wrote:
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Fri, 17 Aug 2012 23:35:12 +0200
>=20
> > @@ -404,7 +404,7 @@ struct dst_entry *inet_csk_route_child_sock(str=
uct
> > sock *sk,>
> >  {
> >       const struct inet_request_sock *ireq =3D inet_rsk(req);
> >       struct inet_sock *newinet =3D inet_sk(newsk);
> >
> > -     struct ip_options_rcu *opt =3D ireq->opt;
> > +     struct ip_options_rcu *opt =3D rcu_dereference(newinet->inet_=
opt);
> >
> >       struct net *net =3D sock_net(sk);
>=20
> We're not inside of a rcu_read_lock() protected section, so this acce=
ss
> is not legitimate.  If you enabled RCU lock debugging, you would have
> triggered a warning in the kernel log.

Oh, sorry... I will resubmit a v2.

Although, I enabled CONFIG_PROVE_RCU (and all other RCU-related debug I=
 could=20
find) and no warning was triggered.


By the way, in dccp_v4_request_recv_sock() is the code:
	newinet->inet_opt	=3D ireq->opt;

Shouldn't this rather be an rcu_assign_pointer() ?


And in cipso_v4_sock_delattr() I believe we should also rather access '=
opt'=20
instead of doing cipso_v4_delopt(&sk_inet->inet_opt) ?


Christoph

--=20
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=E9 Catholique de Louvain
--
