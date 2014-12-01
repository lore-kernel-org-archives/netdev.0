From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v7 28/46] vhost: make features 64 bit
Date: Mon, 01 Dec 2014 04:12:37 +0000
Message-ID: <1417407157.7215.127.camel@decadent.org.uk>
References: <1417359787-10138-1-git-send-email-mst@redhat.com>
	<1417359787-10138-29-git-send-email-mst@redhat.com>
	<547B3B61.3090801@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8667392106295815279=="
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, rusty@au1.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <547B3B61.3090801@cogentembedded.com>
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


--===============8667392106295815279==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qy6KHeFStlY1bi18Qj3Z"


--=-qy6KHeFStlY1bi18Qj3Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-11-30 at 18:44 +0300, Sergei Shtylyov wrote:
> Hello.
>=20
> On 11/30/2014 6:11 PM, Michael S. Tsirkin wrote:
>=20
> > We need to use bit 32 for virtio 1.0
>=20
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > Reviewed-by: Jason Wang <jasowang@redhat.com>
> > ---
> >   drivers/vhost/vhost.h | 4 ++--
> >   1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> > diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> > index 3eda654..c624b09 100644
> > --- a/drivers/vhost/vhost.h
> > +++ b/drivers/vhost/vhost.h
> > @@ -106,7 +106,7 @@ struct vhost_virtqueue {
> >   	/* Protected by virtqueue mutex. */
> >   	struct vhost_memory *memory;
> >   	void *private_data;
> > -	unsigned acked_features;
> > +	u64 acked_features;
> >   	/* Log write descriptors */
> >   	void __user *log_base;
> >   	struct vhost_log *log;
> > @@ -174,6 +174,6 @@ enum {
> >
> >   static inline int vhost_has_feature(struct vhost_virtqueue *vq, int b=
it)
> >   {
> > -	return vq->acked_features & (1 << bit);
> > +	return vq->acked_features & (1ULL << bit);
>=20
>     Erm, wouldn't the high word be just dropped when returning *int*? I t=
hink=20
> you need !!(vq->acked_features & (1ULL << bit)).

Or change the return type to bool.

Ben.

--=20
Ben Hutchings
The first rule of tautology club is the first rule of tautology club.

--=-qy6KHeFStlY1bi18Qj3Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHvquue/yOyVhhEJAQpWRQ//Rgnx+WWqV4UjzYHQPoSp6MvIL26bBpxJ
7C2q0p7pb3Q+8Dokc89hPc7aedPmELhhMTZZIVYgL53K64s6DB9ii4hiCdOT7UXB
GRwazzsQznU3rXk70elpjJ1ZL1vuRWo1vbSXrWQ7eiQKFo7IOjOjNiT6FA90/xWd
PcNMNCRbHozLd8cUOMagxS00GhfkqkHof/qgkTcLelGztI1T1TX+bHXmkXELzvhx
4HZxU3ycVX5Bmn4Q10fmiG0DEO/IOJUaaXL78k2V0LnW77zabrkQ+131SsEA/IPR
Wh2nsZDbaE5VFKoTmlFfPYfQh6W9xl+/kMNN+Fal08aFnosyuHdXQlSPLvuiy0Ro
Exox6/tXqcpzXPHnGh2/JxbTVldUghesNVONgEOqfUibJzwQczaSwL9hDksqYiMQ
DRac881Mev5Yz7VvHADWGaloZbuAWzgMggpI2FX7+gcs7JYz40Xn/C7BPMeoCB0M
UwMMtETiDpXFfFUQsDUL5CFf/Iueyge7+mYEj8A0kMv5a5lZ1lxEy5GnpFiNcqiZ
2K1VwAWdb4epcIbBJjEnqBiQAQVMSo6DkEdH5KYtXHShjtCk27/pB6q5sFRFC/el
UUYm+6ayfOY4SIXiWKyLdaGgKGS7qLd3xeOKjeEUz+uJbO/FABemNuqR75Sr4UDU
+wCIopnAhxk=
=KwA+
-----END PGP SIGNATURE-----

--=-qy6KHeFStlY1bi18Qj3Z--

--===============8667392106295815279==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============8667392106295815279==--
