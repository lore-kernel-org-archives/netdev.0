From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [RFC PATCH] net: cgroup: null ptr dereference in netprio cgroup
 during init
Date: Wed, 18 Jul 2012 09:59:39 +0800
Message-ID: <5006188B.7060606@cn.fujitsu.com>
References: <20120718003316.2979.49278.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, nhorman@tuxdriver.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:31489 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750851Ab2GRB7W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 21:59:22 -0400
In-Reply-To: <20120718003316.2979.49278.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8818=E6=97=A5 08:33, John Fastabend =E5=
=86=99=E9=81=93:
> When the netprio cgroup is built in the kernel cgroup_init will call
> cgrp_create which eventually calls update_netdev_tables. This is
> being called before do_initcalls() so a null ptr dereference occurs
> on init_net.
>=20
> This patch adds a check on init_net.count to verify the structure
> has been initialized. The failure was introduced here,
>=20
> commit ef209f15980360f6945873df3cd710c5f62f2a3e
> Author: Gao feng <gaofeng@cn.fujitsu.com>
> Date:   Wed Jul 11 21:50:15 2012 +0000
>=20
>     net: cgroup: fix access the unallocated memory in netprio cgroup
>=20
> Tested with ping with netprio_cgroup as a module and built in.
>=20
> Marked RFC for now I think DaveM might have a reason why this needs
> some improvement.
>=20
> Reported-by: Mark Rustad <mark.d.rustad@intel.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>=20
>  net/core/netprio_cgroup.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> index b2e9caa..e9fd7fd 100644
> --- a/net/core/netprio_cgroup.c
> +++ b/net/core/netprio_cgroup.c
> @@ -116,6 +116,9 @@ static int update_netdev_tables(void)
>  	u32 max_len;
>  	struct netprio_map *map;


Thanks John.
It's my mistake.

Can we make sure init_net.count is zero here?
I can't find some places to initialize it to zero.

> =20
> +	if (!atomic_read(&init_net.count))
> +		return ret;
> +
>  	rtnl_lock();
>  	max_len =3D atomic_read(&max_prioidx) + 1;
>  	for_each_netdev(&init_net, dev) {
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
