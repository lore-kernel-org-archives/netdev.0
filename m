From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] nfc: netlink: avoid NULL pointer dereference on error
Date: Tue, 20 Oct 2015 06:50:38 +0200
Message-ID: <20151020045038.GE9764@zurbaran.home>
References: <1444210399-3913-1-git-send-email-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Thierry Escande <thierry.escande@linux.intel.com>
To: Vincent =?iso-8859-1?Q?Stehl=E9?= <vincent.stehle@laposte.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444210399-3913-1-git-send-email-vincent.stehle@laposte.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vincent,

On Wed, Oct 07, 2015 at 11:33:19AM +0200, Vincent Stehl=E9 wrote:
> The function nfc_genl_llc_sdreq() can dereference the dev pointer whi=
le
> it is NULL on its error path. Create a new error handling label to av=
oid
> that.
>=20
> This fixes the following coccinelle error:
>=20
>   ./net/nfc/netlink.c:1175:21-24: ERROR: dev is NULL but dereferenced=
=2E
>=20
> Signed-off-by: Vincent Stehl=E9 <vincent.stehle@laposte.net>
> Cc: Thierry Escande <thierry.escande@linux.intel.com>
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> ---
>  net/nfc/netlink.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
> index 853172c..51c48f0 100644
> --- a/net/nfc/netlink.c
> +++ b/net/nfc/netlink.c
> @@ -1111,7 +1111,7 @@ static int nfc_genl_llc_sdreq(struct sk_buff *s=
kb, struct genl_info *info)
>  	dev =3D nfc_get_device(idx);
>  	if (!dev) {
>  		rc =3D -ENODEV;
> -		goto exit;
> +		goto exit_nodev;
>  	}
Julia Lawall sent a better fix that I applied:

-       if (!dev) {
-               rc =3D -ENODEV;
-               goto exit;
-       }
+       if (!dev)
+               return -ENODEV;

Cheers,
Samuel.
