From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] rtnetlink: fix frame size warning in
 rtnl_fill_ifinfo
Date: Tue, 17 Nov 2015 05:10:00 -0800
Message-ID: <1447765800.22599.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447764496-23181-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33497 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbKQNKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 08:10:02 -0500
Received: by pabfh17 with SMTP id fh17so9373654pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 05:10:01 -0800 (PST)
In-Reply-To: <1447764496-23181-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 13:48 +0100, Hannes Frederic Sowa wrote:
> Fix the following warning:
>=20
>   CC      net/core/rtnetlink.o
> net/core/rtnetlink.c: In function =E2=80=98rtnl_fill_ifinfo=E2=80=99:
> net/core/rtnetlink.c:1308:1: warning: the frame size of 2864 bytes is=
 larger than 2048 bytes [-Wframe-larger-than=3D]
>  }
>  ^
> by splitting up the huge rtnl_fill_ifinfo into some smaller ones, so =
we
> don't have the huge frame allocations at the same time.
>=20
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/core/rtnetlink.c | 274 ++++++++++++++++++++++++++++-------------=
----------
>  1 file changed, 152 insertions(+), 122 deletions(-)
>=20
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 504bd17..6f1c181 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1045,15 +1045,156 @@ static int rtnl_phys_switch_id_fill(struct s=
k_buff *skb, struct net_device *dev)
>  	return 0;
>  }
> =20
> +static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
> +					      struct net_device *dev)
> +{
> +	struct nlattr *attr;
> +	struct rtnl_link_stats64 temp;
> +	const struct rtnl_link_stats64 *stats;
> +

Please reorder this in opposite way : longest lines first



> +
> +static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
> +					       struct net_device *dev,
> +					       int vfs_num,
> +					       struct nlattr *vfinfo)
> +{
> +	struct nlattr *vf, *vfstats;
> +	struct ifla_vf_info ivi;
> +	struct ifla_vf_mac vf_mac;
> +	struct ifla_vf_vlan vf_vlan;
> +	struct ifla_vf_rate vf_rate;
> +	struct ifla_vf_tx_rate vf_tx_rate;
> +	struct ifla_vf_spoofchk vf_spoofchk;
> +	struct ifla_vf_link_state vf_linkstate;
> +	struct ifla_vf_rss_query_en vf_rss_query_en;
> +	struct ifla_vf_stats vf_stats;
> +	struct ifla_vf_trust vf_trust;

Same here.

Thanks.
