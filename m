From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] [NET]: Add missing braces to multi-statement if()s
Date: Thu, 1 May 2008 13:53:24 -0700
Message-ID: <20080501135324.58eddc3f@infradead.org>
References: <Pine.LNX.4.64.0805021646000.30402@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36172 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbYEBSx6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 14:53:58 -0400
In-Reply-To: <Pine.LNX.4.64.0805021646000.30402@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 May 2008 16:48:35 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

>=20
> One finds all kinds of crazy things with some shell pipelining.

nice catches!

>=20
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> Cc: David Howells <dhowells@redhat.com>
> ---
>  net/core/sock.c          |    3 ++-
>  net/rxrpc/ar-transport.c |    3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5dbb81b..fa76f04 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -228,11 +228,12 @@ static int sock_set_timeout(long *timeo_p, char
> __user *optval, int optlen) static int warned __read_mostly;
> =20
>  		*timeo_p =3D 0;
> -		if (warned < 10 && net_ratelimit())
> +		if (warned < 10 && net_ratelimit()) {
>  			warned++;
>  			printk(KERN_INFO "sock_set_timeout:
> `%s' (pid %d) " "tries to set negative timeout\n",
>  				current->comm, task_pid_nr(current));
> +		}
>  		return 0;
>  	}
>  	*timeo_p =3D MAX_SCHEDULE_TIMEOUT;
>
> =20

oh my kingdom for a WARN_ON_ONCE() that acts like printk after the
first parameter....
