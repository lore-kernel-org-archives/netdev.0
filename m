From: =?ISO-8859-1?Q?Fran=E7ois_Valenduc?=
	<francois.valenduc@tvcablenet.be>
Subject: Re: [Bugme-new] [Bug 11447] New: /proc/sys/net/ipv4/route/flush not
 found
Date: Fri, 29 Aug 2008 18:35:58 +0200
Message-ID: <48B8256E.5010800@tvcablenet.be>
References: <bug-11447-10286@http.bugzilla.kernel.org/>	<20080828131824.49352fa0.akpm@linux-foundation.org> <20080828.132935.193700612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agave.telenet-ops.be ([195.130.137.77]:42219 "EHLO
	agave.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754009AbYH2QgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 12:36:09 -0400
In-Reply-To: <20080828.132935.193700612.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 28 Aug 2008 13:18:24 -0700
>
>  =20
>> (switched to email.  Please respond via emailed reply-to-all, not vi=
a the
>> bugzilla web interface).
>>    =20
>
> Should be fixed in Linus's tree as of an hour ago, it was a
> permissions issue:
>
> commit d994af0d50efc96b2077978fe9f066992639d525
> Author: Hugh Dickins <hugh@veritas.com>
> Date:   Wed Aug 27 02:35:18 2008 -0700
>
>     ipv4: mode 0555 in ipv4_skeleton
>    =20
>     vpnc on today's kernel says Cannot open "/proc/sys/net/ipv4/route=
/flush":
>     d--------- 0 root root 0 2008-08-26 11:32 /proc/sys/net/ipv4/rout=
e
>     d--------- 0 root root 0 2008-08-26 19:16 /proc/sys/net/ipv4/neig=
h
>    =20
>     Signed-off-by: Hugh Dickins <hugh@veritas.com>
>     Acked-by: Al Viro <viro@zeniv.linux.org.uk>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index e91bafe..6ee5354 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -3121,9 +3121,9 @@ static struct ctl_table empty[1];
>  static struct ctl_table ipv4_skeleton[] =3D
>  {
>  	{ .procname =3D "route", .ctl_name =3D NET_IPV4_ROUTE,
> -	  .child =3D ipv4_route_table},
> +	  .mode =3D 0555, .child =3D ipv4_route_table},
>  	{ .procname =3D "neigh", .ctl_name =3D NET_IPV4_NEIGH,
> -	  .child =3D empty},
> +	  .mode =3D 0555, .child =3D empty},
>  	{ }
>  };
> =20
>
>
>  =20
This commit indeed solves the problem.
