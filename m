From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH net-next V2 3/3] tun: rx batching
Date: Thu, 5 Jan 2017 09:27:50 +0000
Message-ID: <20170105092750.GA25138@stefanha-x1.localdomain>
References: <1482912571-3157-1-git-send-email-jasowang@redhat.com>
	<1482912571-3157-4-git-send-email-jasowang@redhat.com>
	<20170103133303.GC14707@stefanha-x1.localdomain>
	<73da2ef8-2454-5614-d637-0ce7c5287433@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4147202618657407161=="
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <73da2ef8-2454-5614-d637-0ce7c5287433@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============4147202618657407161==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Content-Disposition: inline


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 04, 2017 at 11:03:32AM +0800, Jason Wang wrote:
> On 2017=E5=B9=B401=E6=9C=8803=E6=97=A5 21:33, Stefan Hajnoczi wrote:
> > On Wed, Dec 28, 2016 at 04:09:31PM +0800, Jason Wang wrote:
> > > +static int tun_rx_batched(struct tun_file *tfile, struct sk_buff *sk=
b,
> > > +			  int more)
> > > +{
> > > +	struct sk_buff_head *queue =3D &tfile->sk.sk_write_queue;
> > > +	struct sk_buff_head process_queue;
> > > +	int qlen;
> > > +	bool rcv =3D false;
> > > +
> > > +	spin_lock(&queue->lock);
> > Should this be spin_lock_bh()?  Below and in tun_get_user() there are
> > explicit local_bh_disable() calls so I guess BHs can interrupt us here
> > and this would deadlock.
>=20
> sk_write_queue were accessed only in this function which runs under proce=
ss
> context, so no need for spin_lock_bh() here.

I see, thanks!

Stefan

--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYbhGWAAoJEJykq7OBq3PIhG0IALW5Lv51eiq1ln6fZD/4/SAF
hjH/I8yCmJeWTEFcjRqWnUr/UwQx2m6+3xk5kH2Uh6PeTEHtdtB5igaUoJ0CTvgt
q2RILeiPbLg4/WNIb7vECRsCteeGlYKteirQ9Ftz2Mls8/GHdCW1QlK8+YB3rUln
8s72z5R9S2QnYcSqRu+DzhihB3iCpeLVaJbTtCdT/C155NH0qDqvEfPUUbaap5oS
TruYfTNX8sYOdvJ1vRfLOvhwZg98W44cN+Co9kY7/97RH2qhZutQXtu8TG+val+K
eC5jTgPcmIAn2Q6ruF8Fbd2FP7NWBXk01+QyWmRoYnuYTCr7VxvtT/7t7fE3Jvg=
=W9PW
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--

--===============4147202618657407161==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============4147202618657407161==--
