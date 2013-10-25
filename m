From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/3] vxlan: silence one build warning
Date: Fri, 25 Oct 2013 08:41:34 -0700
Message-ID: <20131025084134.6cfa153a@samsung-9>
References: <1382687360-27794-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382687360-27794-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Oct 2013 15:49:18 +0800
Zhi Yong Wu <zwu.kernel@gmail.com> wrote:

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>=20
> drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
> drivers/net/vxlan.c:2298:11: warning: =E2=80=98sock=E2=80=99 may be u=
sed uninitialized in this function [-Wmaybe-uninitialized]
> drivers/net/vxlan.c:2275:17: note: =E2=80=98sock=E2=80=99 was declare=
d here
>   LD      drivers/net/built-in.o
>=20
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>  drivers/net/vxlan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 2ef5b62..e15f1af 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2272,7 +2272,7 @@ static struct vxlan_sock *vxlan_socket_create(s=
truct net *net, __be16 port,
>  {
>  	struct vxlan_net *vn =3D net_generic(net, vxlan_net_id);
>  	struct vxlan_sock *vs;
> -	struct socket *sock;
> +	struct socket *sock =3D NULL;
>  	struct sock *sk;
>  	int rc =3D 0;
>  	unsigned int h;

This only happens with certain versions of Gcc which have buggy depende=
ncy
analysis. It doesn't happen with Gcc 4.7, think it only shows up in 4.4=
=2E
I would rather not fix the warning this way since it risks masking late=
r bugs if this code ever changes.
