From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Applying inappropriate ioctl operation on socket
 should return ENOTTY
Date: Wed, 27 Apr 2011 12:45:03 +0200
Message-ID: <1303901103.3166.30.camel@edumazet-laptop>
References: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
	 <1303883910.2699.53.camel@edumazet-laptop>
	 <20110427104738.2bdbe228@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lifeng Sun <lifongsun@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110427104738.2bdbe228@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 27 avril 2011 =C3=A0 10:47 +0100, Alan Cox a =C3=A9crit :
> > EINVAL is ok too : Request or argp is not valid.
>=20
> It confuses portable code in some situations
> =20
> > I would say, its not a bug as you claim.=20
>=20
> POSIX and SuS tend to disagree
>=20
> > Its really too late to make such change and risk regressions.
>=20
> We've been quietly doing it for hundreds of cases including the entir=
e
> tty driver. Almost nobody (you included) has actually noticed and in
> doing so we fixed various porting funnies without any reported
> regressions.
>=20
> Networking may be a more tricky one (not that tty wasn't a large one =
we
> fixed) but most of the other driver ones are clearly sensible.
>=20

Well, I wont argue the point, especially if you Ack the changes ;)

My only concern was to not break old applications, I dont know if it is
going to break _any_ of them. Probably these old applications stick wit=
h
old kernels.

If you ask me ENOTTY is plain wrong.
ioctl() is not restricted to terminal devices at all.

Any unknown ioctl command would return ENOTTY, regardless of fd being a
tty or not...

IF we add a new ioctl() to sockets in 2.6.42, using it on 2.6.41 would
give ENOTTY status, and EINVAL status on 2.6.24

Go figure...
