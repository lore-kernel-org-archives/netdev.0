From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [PATCH 3.4-stable v2] ipv6: reallocate addrconf router for ipv6
 address when lo device up
Date: Wed, 6 Aug 2014 15:05:09 +0100
Message-ID: <20140806140509.GB12150@hercules>
References: <53E1E4C9.4010006@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>
To: chenweilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:51944 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbaHFOFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 10:05:15 -0400
Content-Disposition: inline
In-Reply-To: <53E1E4C9.4010006@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2014 at 04:18:17PM +0800, chenweilong wrote:
> It fix the bug 67951 on bugzilla
> https://bugzilla.kernel.org/show_bug.cgi?id=3D67951
>=20
> The patch can't be applied directly, as it' used the function introdu=
ced
> by "commit 94e187c0" ip6_rt_put(), that patch can't be applied direct=
ly
> either.
>

I'm queuing this commit for the 3.11 kernel as well.  Thanks!

Cheers,
--
Lu=EDs

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> From: Gao feng <gaofeng@cn.fujitsu.com>
>=20
> commit 33d99113b1102c2d2f8603b9ba72d89d915c13f5 upstream.
>=20
> This commit don't have a stable tag, but it fix the bug
> no reply after loopback down-up.It's very worthy to be
> applied to stable 3.4 kernels.
>=20
> The bug is 67951 on bugzilla
> https://bugzilla.kernel.org/show_bug.cgi?id=3D67951
>=20
>=20
> CC: Sabrina Dubroca <sd@queasysnail.net>
> CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Reported-by: Weilong Chen <chenweilong@huawei.com>
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> [weilong: s/ip6_rt_put/dst_release]
> Signed-off-by: Chen Weilong <chenweilong@huawei.com>
> ---
>  net/ipv6/addrconf.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index abfa007..25399bf 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2435,8 +2435,18 @@ static void init_loopback(struct net_device *d=
ev)
>  			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
>  				continue;
>=20
> -			if (sp_ifa->rt)
> -				continue;
> +			if (sp_ifa->rt) {
> +				/* This dst has been added to garbage list when
> +				 * lo device down, release this obsolete dst and
> +				 * reallocate a new router for ifa.
> +				 */
> +				if (sp_ifa->rt->dst.obsolete > 0) {
> +					dst_release(&sp_ifa->rt->dst);
> +					sp_ifa->rt =3D NULL;
> +				} else {
> +					continue;
> +				}
> +			}
>=20
>  			sp_rt =3D addrconf_dst_alloc(idev, &sp_ifa->addr, 0);
>=20
> -- 1.7.12
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe stable" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
