From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] core: dev: don't call BUG() on bad input
Date: Mon, 14 Feb 2011 13:16:04 +0100
Message-ID: <4D591D04.4050000@gmail.com>
References: <1297680967-11893-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53692 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753690Ab1BNMQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 07:16:14 -0500
In-Reply-To: <1297680967-11893-1-git-send-email-segoon@openwall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/02/2011 11:56, Vasiliy Kulikov a =E9crit :
> alloc_netdev() may be called with too long name (more that IFNAMSIZ b=
ytes).
> Currently this leads to BUG().  Other insane inputs (bad txqs, rxqs) =
and
> even OOM don't lead to BUG().  Made alloc_netdev() return NULL, like =
on
> other errors.
>
> Signed-off-by: Vasiliy Kulikov<segoon@openwall.com>
> ---
>   Compile tested.
>
>   net/core/dev.c |    5 ++++-
>   1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6392ea0..12ef4b0 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5761,7 +5761,10 @@ struct net_device *alloc_netdev_mqs(int sizeof=
_priv, const char *name,
>   	size_t alloc_size;
>   	struct net_device *p;
>
> -	BUG_ON(strlen(name)>=3D sizeof(dev->name));
> +	if (strnlen(name, sizeof(dev->name))>=3D sizeof(dev->name)) {

"size_t strnlen(const char *s, size_t maxlen) : The strnlen() function =
returns strlen(s), if that is=20
less than maxlen, or maxlen if there is no '\0' character among the fir=
st maxlen characters pointed=20
to by s."

How can strnlen(name, sizeof(dev->name)) be greater than sizeof(dev->na=
me)?

Shouldn't it be "if (strnlen(name, sizeof(dev->name)) =3D=3D sizeof(dev=
->name))" instead?

         Nicolas.

> +		pr_err("alloc_netdev: Too long device name \n");
> +		return NULL;
> +	}
>
>   	if (txqs<  1) {
>   		pr_err("alloc_netdev: Unable to allocate device "

