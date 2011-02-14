From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH v2] core: dev: don't call BUG() on bad input
Date: Mon, 14 Feb 2011 17:16:00 +0200
Message-ID: <AANLkTimidxVJxw-XKTWwCZh8k_vKHDeqxAwVbY6+aJ6x@mail.gmail.com>
References: <1297694579-23611-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1297694579-23611-1-git-send-email-segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 14, 2011 at 4:42 PM, Vasiliy Kulikov <segoon@openwall.com> =
wrote:
> alloc_netdev() may be called with too long name (more that IFNAMSIZ b=
ytes).
> Currently this leads to BUG(). =A0Other insane inputs (bad txqs, rxqs=
) and
> even OOM don't lead to BUG(). =A0Made alloc_netdev() return NULL, lik=
e on
> other errors.

> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5761,7 +5761,10 @@ struct net_device *alloc_netdev_mqs(int sizeof=
_priv, const char *name,
> =A0 =A0 =A0 =A0size_t alloc_size;
> =A0 =A0 =A0 =A0struct net_device *p;
>
> - =A0 =A0 =A0 BUG_ON(strlen(name) >=3D sizeof(dev->name));
> + =A0 =A0 =A0 if (strnlen(name, sizeof(dev->name)) >=3D sizeof(dev->n=
ame)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("alloc_netdev: Too long device n=
ame\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 }

Netdevice name isn't some random junk you get from userspace, so BUG is=
 fine.
