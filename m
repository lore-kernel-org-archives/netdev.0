From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 13:11:27 +0100
Message-ID: <20091203131127.131e9122@houba>
References: <20091130213727.2f4047d2@houba>
	<alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
	<20091201211945.505d3c98@houba>
	<alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
	<20091202085925.472136e2@houba>
	<alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
	<20091202154403.GB30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
	<20091202183451.173db5f2@houba>
	<4B16BD58.3040802@tvk.rwth-aachen.de>
	<20091203085933.GD30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:56963 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847AbZLCMLp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:11:45 -0500
In-Reply-To: <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thu, 3 Dec 2009 12:29:39 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :

> Opinions, Dave?, Greg?
>=20
> Now back to the issue...
>=20
> You said in the other mail that "All further test are on linus-stable=
=20
> tree.", which has this contradiction that Linus does not maintain
> stable trees. Which exactly was the tree used for the .9. test

Sorry I'm confused and so confuse you.
=46or .9 .10 and now I'm only using :=20
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
=20
> Linus' tree or the 2.6.31 stable tree? I suppose the former since the
> revert wouldn't apply to 2.6.31 so I just want to confirm.

I didn't keep the source of the old 2.6.31 kernel I have.=20
So it's either=20
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
or
git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6-stable.g=
it

> Nice thinking indeed Damian, thanks. ...But but, where exactly did
> you print? ...There are multiple returns and the return false branch
> is expected to have a zero retrans_stamp in a typical case but that
> is not a problem because we never use the value.

Here is the code :
http://www.starox.org/pub/scp_stall/printk_retrans_stamp.patch

> ...Anyway, if I'm wrong with my suspicion and it still holds that we
> have zero retrans_stamp in the substraction too, it could have
> something to do with this snippet:
>=20
> static void tcp_try_to_open(struct sock *sk, int flag)
> {
>         struct tcp_sock *tp =3D tcp_sk(sk);
>=20
>         tcp_verify_left_out(tp);
>=20
>         if (!tp->frto_counter && tp->retrans_out =3D=3D 0)
>                 tp->retrans_stamp =3D 0;
>=20
> ...It bit me last time when FRTO was enabled after very small
> modification (without running a full verification after the trivial
> looking modification). ...So I've worked around this clearing for
> FRTO as you can see :-).

:)

> Also, we have the another mystery to be solved, the fast
> retransmission is not triggered for some reason (or alternatively not
> captured in to a log), even in the working .9. case. It would be easy
> to see whether it works at all from TCP point of view by looking into
> mibs once you have have some transfers in a working configuration:
>=20
> grep -A1 TCP /proc/net/netstat

I will try this evening. I can do test only outside office hours.

--=20
=46r=C3=A9d=C3=A9ric Leroy
