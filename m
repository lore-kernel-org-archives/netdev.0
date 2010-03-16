From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 1/1] NET: netpoll, fix potential NULL ptr dereference
Date: Tue, 16 Mar 2010 09:57:34 -0700
Message-ID: <97949e3e1003160957q377b3e78g25dc095fc835f65d@mail.gmail.com>
References: <1268753394-17765-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Daniel Borkmann <danborkmann@googlemail.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268753394-17765-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: chavey@google.com

On Tue, Mar 16, 2010 at 8:29 AM, Jiri Slaby <jslaby@suse.cz> wrote:
> Stanse found that one error path in netpoll_setup dereferences npinfo
> even though it is NULL. Avoid that by adding new label and go to that
> instead.
>
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Daniel Borkmann <danborkmann@googlemail.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
> =A0net/core/netpoll.c | =A0 =A04 ++--
> =A01 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 7aa6972..d4ec38f 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -735,7 +735,7 @@ int netpoll_setup(struct netpoll *np)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0npinfo =3D kmalloc(sizeof(*npinfo), GF=
P_KERNEL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!npinfo) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto release;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto put;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0npinfo->rx_flags =3D 0;
> @@ -845,7 +845,7 @@ int netpoll_setup(struct netpoll *np)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(npinfo);
> =A0 =A0 =A0 =A0}
> -
> +put:
> =A0 =A0 =A0 =A0dev_put(ndev);
> =A0 =A0 =A0 =A0return err;
> =A0}
> --
> 1.7.0.1
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
