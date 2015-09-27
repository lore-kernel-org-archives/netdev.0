From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 02/23] usb-gadget: use per-attribute show and store
 methods
Date: Sun, 27 Sep 2015 10:50:53 -0500
Message-ID: <20150927155053.GD16364@saruman.tx.rr.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-3-git-send-email-hch@lst.de>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Xm/fll+QQv+hsKip"
Cc: Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>, Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	<target-devel@vger.kernel.org>, <cluster-devel@redhat.com>,
	<ocfs2-devel@oss.oracle.com>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443189000-13398-3-git-send-email-hch@lst.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Xm/fll+QQv+hsKip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 25, 2015 at 06:49:39AM -0700, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/usb/gadget/configfs.c       | 295 ++++++++++++++----------------=
------
>  include/linux/usb/gadget_configfs.h |  19 +--
>  2 files changed, 118 insertions(+), 196 deletions(-)
>=20
> diff --git a/drivers/usb/gadget/configfs.c b/drivers/usb/gadget/configfs.c
> index 294eb74..163d305 100644
> --- a/drivers/usb/gadget/configfs.c
> +++ b/drivers/usb/gadget/configfs.c
> @@ -64,6 +64,11 @@ struct gadget_info {
>  	char qw_sign[OS_STRING_QW_SIGN_LEN];
>  };
> =20
> +static inline struct gadget_info *to_gadget_info(struct config_item *ite=
m)
> +{
> +	 return container_of(to_config_group(item), struct gadget_info, group);
> +}

this (and the other helper below) could be macros just fine. Are you 100% c=
ompiler
will *always* inline these helpers. The likelyhood of not inlining is minim=
al, sure,
but what do we get for writing these as functions instead of macros ?

also, lacking commit log

--=20
balbi

--Xm/fll+QQv+hsKip
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWCBBcAAoJEIaOsuA1yqREMDEP/1AK1qa1l8b8beNJXAPqAhDo
qPxKRL3VtI0pSID9TQCn/jL8CrgqQtZ5gjeVFuFrSoU3A5dWsODHWWDhXB+2F4Kd
YW5kQns9N3FEYQr98oi9Q6qRqiMEuUaI7BXStCA5ojQALusBlkH5QoLyTazWFbNe
nkCPnZ+j4RWfz40YtNDOW312Aa3+J9FqAfd7xwvfkJw3Y3nnrzAG1NMQUN4zcgsz
KfpDufqGCC9lFbTH2QReY/+pdOilurJqCrGuzpXmH9HzsrnBOuOsS9WmErv2/4KI
t9VKGeBQXBmZjHQ10UY8Uzc9zqqfXaSU5F64Cc0qwVdLAr3CvRV2tkHKIKa/CSYz
Av68DO4WFRHC9DnNfIrA0cjfGl6pnJwHJ6z5TCVRZ7T9+nrYWwsEToB6s8TBsgJ9
00lM9SagLYGGaCCYWTXzljsQQZacTUJ9G33yOedVwSULFfws+gMZqt5JdZedl9Eh
uAo6a8UPk/LfdU380nKZIPbchUEyrZEn7/K22p4/qiGOq3VztrRCsuhcmDOWjONb
mxBed4l5dQCihkeBvsPZlAKbf68a0RODng81YM8Pnxhxa2Qfbd3QzZNBheyFnvKK
d6Qd8DZoAWpGw9367BnyUN9ZFZWoyQqOOMjvdcOhOfi6nsNN7mQAoxLBlu8eMXKm
wbgtel7kA3fA2c47r3/0
=18ir
-----END PGP SIGNATURE-----

--Xm/fll+QQv+hsKip--
