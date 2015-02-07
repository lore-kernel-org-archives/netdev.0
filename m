From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] vxlan: Wrong type passed to %pIS
Date: Fri, 6 Feb 2015 21:13:31 -0800
Message-ID: <CAM_iQpWGR6zLrGLGsMPM1Y-z45Nd4XO3X_H1KDTedsz2=5mXng@mail.gmail.com>
References: <1423275451-3663-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:38062 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbbBGFNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 00:13:31 -0500
In-Reply-To: <1423275451-3663-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 6, 2015 at 6:17 PM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> src_ip is a pointer to a union vxlan_addr, one member of which is a
> struct sockaddr. Passing a pointer to src_ip is wrong; one should pass
> the value of src_ip itself. Since %pIS formally expects something of
> type struct sockaddr*, let's pass a pointer to the appropriate union
> member, though this of course doesn't change the generated code.
>


It is a union, this doesn't harm.

> Fixes: e4c7ed415387 ("vxlan: add ipv6 support")
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  drivers/net/vxlan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index a8c755dcab14..11defbb24183 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -991,7 +991,7 @@ static bool vxlan_snoop(struct net_device *dev,
>                 if (net_ratelimit())
>                         netdev_info(dev,
>                                     "%pM migrated from %pIS to %pIS\n",
> -                                   src_mac, &rdst->remote_ip, &src_ip);
> +                                   src_mac, &rdst->remote_ip.sa, &src_ip->sa);
>
>                 rdst->remote_ip = *src_ip;
>                 f->updated = jiffies;

Since you are on it, there is another similar place in vxlan too.
