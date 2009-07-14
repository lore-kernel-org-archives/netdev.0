From: Eric Van Hensbergen <ericvh@gmail.com>
Subject: Re: [PATCH] [net/9p]: default 9p transport module fix
Date: Tue, 14 Jul 2009 13:29:19 -0500
Message-ID: <a4e6962a0907141129w23654edbp1ea309b19bf0b546@mail.gmail.com>
References: <1247492991-26009-1-git-send-email-adkulkar@umail.iu.edu>
	 <1247492991-26009-2-git-send-email-adkulkar@umail.iu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Abhishek Kulkarni <adkulkar@umail.iu.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755336AbZGNS3Y@vger.kernel.org>
In-Reply-To: <1247492991-26009-2-git-send-email-adkulkar@umail.iu.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

applied v9fs-devel

On Mon, Jul 13, 2009 at 8:49 AM, Abhishek Kulkarni<adkulkar@umail.iu.ed=
u> wrote:
> The default 9p transport module is not chosen unless an option parame=
ter (any)
> is passed to mount, which thus returns a ENOPROTOSUPPORT. This fix mo=
ves the
> check out of parse_opts into p9_client_create.
>
> Signed-off-by: Abhishek Kulkarni <adkulkar@umail.iu.edu>
> ---
> :100644 100644 cc25e63... 787ccdd... M =A0net/9p/client.c
> =A0net/9p/client.c | =A0 =A06 +++---
> =A01 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/9p/client.c b/net/9p/client.c
> index cc25e63..787ccdd 100644
> --- a/net/9p/client.c
> +++ b/net/9p/client.c
> @@ -117,9 +117,6 @@ static int parse_opts(char *opts, struct p9_clien=
t *clnt)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (!clnt->trans_mod)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 clnt->trans_mod =3D v9fs_get_default_tr=
ans();
> -
> =A0 =A0 =A0 =A0kfree(options);
> =A0 =A0 =A0 =A0return ret;
> =A0}
> @@ -689,6 +686,9 @@ struct p9_client *p9_client_create(const char *de=
v_name, char *options)
> =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
>
> + =A0 =A0 =A0 if (!clnt->trans_mod)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clnt->trans_mod =3D v9fs_get_default_tr=
ans();
> +
> =A0 =A0 =A0 =A0if (clnt->trans_mod =3D=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EPROTONOSUPPORT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0P9_DPRINTK(P9_DEBUG_ERROR,
> --
> 1.6.0.4
>
>
