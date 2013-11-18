From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Mon, 18 Nov 2013 11:44:48 +0100
Message-ID: <20131118104448.GI16823@kw.sim.vm.gnt>
References: <8761s0cqhh.fsf@natisbad.org>
 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
 <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu>
 <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
 <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
 <20131117141940.GA18569@1wt.eu> <20131118112601.65feb708@skate>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8600137922465317516=="
Cc: netdev@vger.kernel.org, Arnaud Ebalard <arno@natisbad.org>,
 Vincent Donnefort <vdonnefort@gmail.com>, edumazet@google.com,
 Cong Wang <xiyou.wangcong@gmail.com>, Willy Tarreau <w@1wt.eu>,
 linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20131118112601.65feb708@skate>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============8600137922465317516==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="aqWxf8ydqYKP8htK"
Content-Disposition: inline


--aqWxf8ydqYKP8htK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 18, 2013 at 11:26:01AM +0100, Thomas Petazzoni wrote:
> Willy, All,
>=20
> On Sun, 17 Nov 2013 15:19:40 +0100, Willy Tarreau wrote:
>=20
> > On Wed, Nov 13, 2013 at 08:22:57AM +0100, Willy Tarreau wrote:
> > > On Tue, Nov 12, 2013 at 04:34:24PM +0100, Arnaud Ebalard wrote:
> > > > Can you give a pre-3.11.7 kernel a try if you find the time? I
> > > > started working on RN102 during 3.10-rc cycle but do not remember
> > > > if I did the first preformance tests on 3.10 or 3.11. And if you
> > > > find more time, 3.11.7 would be nice too ;-)
> > >=20
> > > Still have not found time for this but I observed something
> > > intriguing which might possibly match your experience : if I use
> > > large enough send buffers on the mirabox and receive buffers on the
> > > client, then the traffic drops for objects larger than 1 MB. I have
> > > quickly checked what's happening and it's just that there are
> > > pauses of up to 8 ms between some packets when the TCP send window
> > > grows larger than about 200 kB. And since there are no drops, there
> > > is no reason for the window to shrink. I suspect it's exactly
> > > related to the issue explained by Eric about the timer used to
> > > recycle the Tx descriptors. However last time I checked, these ones
> > > were also processed in the Rx path, which means that the ACKs that
> > > flow back should have had the same effect as a Tx IRQ (unless I'd
> > > use asymmetric routing, which was not the case). So there might be
> > > another issue. Ah, and it only happens with GSO.
>=20
> I haven't read the entire discussion yet, but do you guys have
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/dri=
vers/clk/mvebu?id=3D1022c75f5abd3a3b25e679bc8793d21bedd009b4
> applied? It got merged recently, and it fixes a number of networking
> problems on Armada 370.
>=20
> I've added Simon Guinot in Cc, who is the author of this patch.

I don't think it is related. We also have noticed a huge performance
regression. Reverting the following patch restores the rate:

c9eeec26 tcp: TSQ can use a dynamic limit

I don't understand why...

Regards,

Simon

>=20
> Best regards,
>=20
> Thomas
> --=20
> Thomas Petazzoni, CTO, Free Electrons
> Embedded Linux, Kernel and Android engineering
> http://free-electrons.com

--aqWxf8ydqYKP8htK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlKJ76AACgkQgtp0PDeOcDqexgCdHaP0qT9v5k/tF9rySIwGfrfR
9s8Amwbm8FH6oUbdYajVtMQ8su7OlM2d
=1u7U
-----END PGP SIGNATURE-----

--aqWxf8ydqYKP8htK--


--===============8600137922465317516==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============8600137922465317516==--
