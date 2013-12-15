From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH v2 5/9] drivers: net: Put prototype declaration for
 function sbni_probe() in sbni.c
Date: Sat, 14 Dec 2013 19:41:49 -0800
Message-ID: <20131215034148.GA1573@leaf>
References: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
 <dd984c99d43214c39b23f95e9a58f3a675147e69.1386911124.git.rashika.kheria@gmail.com>
 <20131214.222658.766340465002992773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rashika.kheria@gmail.com, linux-kernel@vger.kernel.org,
	sebastian@breakpoint.cc, sachin.kamat@linaro.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131214.222658.766340465002992773.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 14, 2013 at 10:26:58PM -0500, David Miller wrote:
> From: Rashika Kheria <rashika.kheria@gmail.com>
> Date: Sat, 14 Dec 2013 17:55:42 +0530
>=20
> > This patch declares the prototype for the function sbni_probe() in =
file sbni.c.
> >=20
> > Thus, it also removes the following warning in wan/sbni.c:
> > drivers/net/wan/sbni.c:224:12: warning: no previous prototype for =E2=
=80=98sbni_probe=E2=80=99 [-Wmissing-prototypes]
> >=20
> > Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> > ---
> >=20
> > This revision fixes the following issues of the previous revision:
> > Incorrect fix
> >=20
> >  drivers/net/wan/sbni.c |    1 +
> >  1 file changed, 1 insertion(+)
> >=20
> > diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
> > index 388ddf6..5061ffd 100644
> > --- a/drivers/net/wan/sbni.c
> > +++ b/drivers/net/wan/sbni.c
> > @@ -221,6 +221,7 @@ static void __init sbni_devsetup(struct net_dev=
ice *dev)
> >  	dev->netdev_ops =3D &sbni_netdev_ops;
> >  }
> > =20
> > +int __init sbni_probe(int unit);
> >  int __init sbni_probe(int unit)
>=20
> This is not the correct way to fix this kind of warning, an exported
> function needs to appear in a header file so that both the definition
> and any callers of this function will see the same declaration in tha=
t
> header file.

It should, yes; however, in this case, the function is one of several
dozen that are directly prototyped and used by drivers/net/Space.c, and
there's no header file prototyping any of those functions.

Do you have a suggestion for what header file should contain a prototyp=
e
for this probe function?

- Josh Triplett
