From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] Correct assignment of uid to gid in credentials
Date: Tue, 09 Aug 2011 04:43:54 +0200
Message-ID: <1312857834.2531.15.camel@edumazet-laptop>
References: <1312841316.2576.49.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>, ak@linux.intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312841316.2576.49.camel@schen9-DESK>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 08 ao=C3=BBt 2011 =C3=A0 15:08 -0700, Tim Chen a =C3=A9crit :
> This patch corrects an erroneous assignment of uid to gid in credenti=
als
> update.
>=20
> Tim
>=20
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> diff --git a/net/core/scm.c b/net/core/scm.c
> index 4c1ef02..811b53f 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
> @@ -192,7 +192,7 @@ int __scm_send(struct socket *sock, struct msghdr
> *msg, struct scm_cookie *p)
>  					goto error;
> =20
>  				cred->uid =3D cred->euid =3D p->creds.uid;
> -				cred->gid =3D cred->egid =3D p->creds.uid;
> +				cred->gid =3D cred->egid =3D p->creds.gid;
>  				put_cred(p->cred);
>  				p->cred =3D cred;
>  			}
>=20
>=20

Good catch Tim.

BTW your patch is a bit flawed : one wrapped line and "---" marker
missing.

Could you add in Changelog bug came from commit 257b5358b32f17
(scm: Capture the full credentials of the scm sender) to ease stable
teams work ?
(linux-2.6.36 was the first kernel to include this commit)
