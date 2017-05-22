From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH 2/2] vhost/scsi: Delete error messages for failed memory
	allocations in five functions
Date: Mon, 22 May 2017 10:43:20 +0100
Message-ID: <20170522094320.GE12205@stefanha-x1.localdomain>
References: <bafa65e4-08fe-efdb-d836-7657e8a64749@users.sourceforge.net>
	<babc429d-6440-92aa-e1d0-eee2636a8d0f@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1307790743056350687=="
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, Wolfram Sang <wsa@the-dreams.de>,
	kernel-janitors@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <babc429d-6440-92aa-e1d0-eee2636a8d0f@users.sourceforge.net>
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


--===============1307790743056350687==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="brEuL7wsLY8+TuWz"
Content-Disposition: inline


--brEuL7wsLY8+TuWz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, May 20, 2017 at 04:32:17PM +0200, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 20 May 2017 15:50:30 +0200
>=20
> Omit seven extra messages for memory allocation failures in these functio=
ns.
>=20
> This issue was detected by using the Coccinelle software.
>=20
> Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-R=
efactor_Strings-WSang_0.pdf

Please include an actual explanation for this change instead of linking
to slides.  Why are you trying to get rid of memory allocation failure
messages?

> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/vhost/scsi.c | 24 +++++++-----------------
>  1 file changed, 7 insertions(+), 17 deletions(-)
>=20
> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index 650533916c19..49d07950e2e5 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -417,5 +417,4 @@ vhost_scsi_allocate_evt(struct vhost_scsi *vs,
>  	if (!evt) {
> -		vq_err(vq, "Failed to allocate vhost_scsi_evt\n");

#define vq_err(vq, fmt, ...) do {                                  \
                pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
                if ((vq)->error_ctx)                               \
                                eventfd_signal((vq)->error_ctx, 1);\
        } while (0)

You silently dropped the eventfd_signal() call.  Please explain.

--brEuL7wsLY8+TuWz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZIrK4AAoJEJykq7OBq3PIR6gH/iErbMWvzcSjDhiYspNTQ3L5
81uxAo7qujqQqTQQZMUqKwqKjLMQqJPcJ8ytjXN6eoGRvoJ2QfUlkct0RmBoj6zM
c34igRQi1GTHtctOm58z74O9955PZQWa0jUlXN7gd1CSslat7xqm8H+Bl1rWl2Ti
gbOW/qDewsGwGL3zjoFK+/p8TiCBg+wg4a/R9QOupIS/gy61CNHfVNnztoU0Ts5j
tA2be0BsHm1O4sKSLIlIS7ehhkL11eAknqIy79mAGviHl/lyX0MJ7qBYWCEsHQhp
bzAYU4qWnrpmCQDvx942dUnjs2Z/dFXH9Cvuoxi1XNsaz0lH10LEsfikwqr3DXs=
=Y9sL
-----END PGP SIGNATURE-----

--brEuL7wsLY8+TuWz--

--===============1307790743056350687==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============1307790743056350687==--
