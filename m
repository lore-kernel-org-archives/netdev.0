From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] tcp: bind() fix autoselection to share ports
Date: Wed, 25 Jan 2012 19:47:35 +0100
Message-ID: <1327517255.2605.1.camel@edumazet-laptop>
References: <1327516492-9045-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Marcelo Leitner <mleitner@redhat.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41698 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876Ab2AYSrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 13:47:39 -0500
Received: by werb13 with SMTP id b13so4044180wer.19
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 10:47:38 -0800 (PST)
In-Reply-To: <1327516492-9045-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 janvier 2012 =C3=A0 16:34 -0200, Flavio Leitner a =C3=A9=
crit :
> The current code checks for conflicts when the application
> requests a specific port.  If there is no conflict, then
> the request is granted.
>=20
> On the other hand, the port autoselection done by the kernel
> fails when all ports are bound even when there is a port
> with no conflict available.
>=20
> The fix changes port autoselection to check if there is a
> conflict and use it if not.
>=20
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
>  net/ipv4/inet_connection_sock.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
> index 2e4e244..ecd19b5 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -128,6 +128,11 @@ again:
>  							goto have_snum;
>  						}
>  					}
> +					if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
> +						spin_unlock(&head->lock);
> +						snum =3D rover;
> +						goto have_snum;
> +					}
>  					goto next;
>  				}
>  			break;



Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
