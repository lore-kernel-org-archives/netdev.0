From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Fri, 27 May 2011 21:56:59 +0200
Message-ID: <1306526219.2533.3.camel@edumazet-laptop>
References: <201104250033.03401.maxi@daemonizer.de>
	 <1303878240.2699.41.camel@edumazet-laptop>
	 <1303878771.2699.44.camel@edumazet-laptop>
	 <201104271352.00601.maxi@daemonizer.de>
	 <20110512211033.GA3468@dev1756.snc6.facebook.com>
	 <1305234953.2831.2.camel@edumazet-laptop>
	 <20110524213327.GA3917@dev1756.snc6.facebook.com>
	 <1306291469.3305.11.camel@edumazet-laptop>
	 <20110525060609.GA32244@dev1756.snc6.facebook.com>
	 <1306305331.3305.22.camel@edumazet-laptop>  <4DDEAA3C.7020502@fb.com>
	 <1306439246.2543.10.camel@edumazet-laptop>  <4DDECA9B.8080206@fb.com>
	 <1306447292.2543.32.camel@edumazet-laptop>  <4DDEEBC5.80804@fb.com>
	 <1306466831.2543.58.camel@edumazet-laptop>  <4DDFE4D6.4010000@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>,
	Yann Dupont <Yann.Dupont@univ-nantes.fr>,
	Denys Fedoryshchenko <denys@visp.net.lb>
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DDFE4D6.4010000@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 27 mai 2011 =C3=A0 10:52 -0700, Arun Sharma a =C3=A9crit :
> On 5/26/11 8:27 PM, Eric Dumazet wrote:
>=20
> Looks good. Thanks for taking care of this.
>=20
> > +static bool atomic_add_unless_return(atomic_t *ptr, int a, int u, =
int *newv)
> > +{
> > +	int cur, old =3D atomic_read(ptr);
> > +
> > +	while (old !=3D u) {
> > +		*newv =3D old + a;
> > +		cur =3D atomic_cmpxchg(ptr, old, *newv);
> > +		if (cur =3D=3D old)
> > +			return true;
> > +		old =3D cur;
> > +	}
> > +	return false;
> > +}
>=20
> This looks very similar to atomic_add_unless(). If we had a
>=20
> __atomic_add_unless() that returned "old", we could then do:
>=20
> atomic_add_unless() { return __atomic_add_unless() !=3D u }
> atomic_add_unless_return() { return __atomic_add_unless() + a}
>=20

Sure !

I preferred to not touch lot of files in kernel (atomic_add_unless() is
defined in several files) because its a stable candidate patch (2.6.36+=
)

So a cleanup patch for 2.6.40+ is certainly doable, do you want to do
this ?

Thanks
