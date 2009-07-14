From: Eric Van Hensbergen <ericvh@gmail.com>
Subject: Re: [PATCH] [net/9p] Possible regression in p9_client_stat
Date: Tue, 14 Jul 2009 13:29:57 -0500
Message-ID: <a4e6962a0907141129r7c7fd19jb6da6ff229433a13@mail.gmail.com>
References: <1247492991-26009-1-git-send-email-adkulkar@umail.iu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Abhishek Kulkarni <adkulkar@umail.iu.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755434AbZGNSaA@vger.kernel.org>
In-Reply-To: <1247492991-26009-1-git-send-email-adkulkar@umail.iu.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

applied v9fs-devel

On Mon, Jul 13, 2009 at 8:49 AM, Abhishek Kulkarni<adkulkar@umail.iu.ed=
u> wrote:
> Fix a possible regression with p9_client_stat where it can try to kfr=
ee an ERR_PTR
> after an erroneous p9pdu_readf. Also remove an unnecessary data buffe=
r increment
> in p9_client_read.
>
> Signed-off-by: Abhishek Kulkarni <adkulkar@umail.iu.edu>
> ---
> :100644 100644 dd43a82... cc25e63... M =A0net/9p/client.c
> =A0net/9p/client.c | =A0 =A07 ++-----
> =A01 files changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/net/9p/client.c b/net/9p/client.c
> index dd43a82..cc25e63 100644
> --- a/net/9p/client.c
> +++ b/net/9p/client.c
> @@ -1098,7 +1098,6 @@ p9_client_read(struct p9_fid *fid, char *data, =
char __user *udata, u64 offset,
>
> =A0 =A0 =A0 =A0if (data) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memmove(data, dataptr, count);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 data +=3D count;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (udata) {
> @@ -1192,9 +1191,9 @@ struct p9_wstat *p9_client_stat(struct p9_fid *=
fid)
>
> =A0 =A0 =A0 =A0err =3D p9pdu_readf(req->rc, clnt->dotu, "wS", &ignore=
d, ret);
> =A0 =A0 =A0 =A0if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D ERR_PTR(err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p9pdu_dump(1, req->rc);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto free_and_error;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_free_req(clnt, req);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0P9_DPRINTK(P9_DEBUG_9P,
> @@ -1211,8 +1210,6 @@ struct p9_wstat *p9_client_stat(struct p9_fid *=
fid)
> =A0 =A0 =A0 =A0p9_free_req(clnt, req);
> =A0 =A0 =A0 =A0return ret;
>
> -free_and_error:
> - =A0 =A0 =A0 p9_free_req(clnt, req);
> =A0error:
> =A0 =A0 =A0 =A0kfree(ret);
> =A0 =A0 =A0 =A0return ERR_PTR(err);
> --
> 1.6.0.4
>
>
