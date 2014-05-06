From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: Re: [PATCH 2/3] rtnetlink: fix potential NULL pointer dereference
Date: Tue, 06 May 2014 18:26:17 +0300
Message-ID: <7039871.D07mH35iXC@tuxracer>
References: <cover.1399388943.git.popovich_sergei@mail.ru> <d525a30e52966da564bc3e4de31c4197a989b2ae.1399388943.git.popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp44.i.mail.ru ([94.100.177.104]:33905 "EHLO smtp44.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755205AbaEFP1O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:27:14 -0400
Received: from [195.234.68.4] (port=41275 helo=tuxracer.localnet)
	by smtp44.i.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1WhhGy-0002hM-A3
	for netdev@vger.kernel.org; Tue, 06 May 2014 19:27:12 +0400
In-Reply-To: <d525a30e52966da564bc3e4de31c4197a989b2ae.1399388943.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D0=BF=D0=B8=D1=81=D1=8C=D0=BC=D0=B5 =D0=BE=D1=82 6 =D0=BC=D0=B0=
=D1=8F 2014 18:13:16 =D0=BF=D0=BE=D0=BB=D1=8C=D0=B7=D0=BE=D0=B2=D0=B0=D1=
=82=D0=B5=D0=BB=D1=8C Sergey Popovich =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=
=B0=D0=BB:
> Now since commit fbdc1e8c6b79 (rtnetlink: walk through all devs in
> netns safely on link params change) group of network devices can
> be moved into another network namespace, there is NULL pointer
> dereference in the do_setlink() as it get's called from
> rtnl_group_changelink() with ifname =3D=3D NULL.
>=20
> Fixes: e7ed828f10bd netlink: support setting devgroup parameters
> Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>

Not needed, self-rejected patch, ifm->ifi_index is =3D=3D 0 when
calling from rtnl_group_changelink().

Sorry for noise.

> ---
>  net/core/rtnetlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 95258e2..188c060 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1484,7 +1484,7 @@ static int do_setlink(struct net_device *dev, s=
truct
> ifinfomsg *ifm, * name provided implies that a name change has been
>  	 * requested.
>  	 */
> -	if (ifm->ifi_index > 0 && ifname[0]) {
> +	if (ifname && ifname[0] && ifm->ifi_index > 0) {
>  		err =3D dev_change_name(dev, ifname);
>  		if (err < 0)
>  			goto errout;

--=20
SP5474-RIPE
Sergey Popovich
