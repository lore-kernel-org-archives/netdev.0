From: "Yan, Zheng " <yanzheng@21cn.com>
Subject: Re: [PATCH] Ipv6: Delete rcu_read_lock
Date: Thu, 29 Sep 2011 16:16:58 +0800
Message-ID: <CAAM7YAnE4w4y6YWWxk0QGOX8Y6AZQHHQBuVMoRuSm=GtALAx=Q@mail.gmail.com>
References: <1317282414-13368-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:55577 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755848Ab1I2IQ7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 04:16:59 -0400
Received: by vws1 with SMTP id 1so226655vws.19
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2011 01:16:58 -0700 (PDT)
In-Reply-To: <1317282414-13368-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 29, 2011 at 3:46 PM,  <rongqing.li@windriver.com> wrote:
> From: Roy.Li <rongqing.li@windriver.com>
>
> Delete rcu_read_lock, it is redundant.
>
> Signed-off-by: Roy.Li <rongqing.li@windriver.com>
> ---
> =A0net/ipv6/ndisc.c | =A0 =A03 ---
> =A01 files changed, 0 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 9da6e02..dd633ff 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -370,17 +370,14 @@ static int ndisc_constructor(struct neighbour *=
neigh)
> =A0 =A0 =A0 =A0struct neigh_parms *parms;
> =A0 =A0 =A0 =A0int is_multicast =3D ipv6_addr_is_multicast(addr);
>
> - =A0 =A0 =A0 rcu_read_lock();
> =A0 =A0 =A0 =A0in6_dev =3D in6_dev_get(dev);
> =A0 =A0 =A0 =A0if (in6_dev =3D=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0parms =3D in6_dev->nd_parms;
> =A0 =A0 =A0 =A0__neigh_parms_put(neigh->parms);
> =A0 =A0 =A0 =A0neigh->parms =3D neigh_parms_clone(parms);
> - =A0 =A0 =A0 rcu_read_unlock();
>
> =A0 =A0 =A0 =A0neigh->type =3D is_multicast ? RTN_MULTICAST : RTN_UNI=
CAST;
> =A0 =A0 =A0 =A0if (!dev->header_ops) {
> --

I think the rcu_read_lock protects in6_dev->nd_parms.

Yan, Zheng
