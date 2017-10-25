From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [Patch net-next] tipc: fix a dangling pointer
Date: Wed, 25 Oct 2017 07:58:09 +0000
Message-ID: <AM4PR07MB17140DDFEA01B34334BE7DAD9A440@AM4PR07MB1714.eurprd07.prod.outlook.com>
References: <20171024224449.8197-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Ying Xue <ying.xue@windriver.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:47195 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932101AbdJYH6N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 03:58:13 -0400
In-Reply-To: <20171024224449.8197-1-xiyou.wangcong@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked. Thank you.

///jon

> -----Original Message-----
> From: Cong Wang [mailto:xiyou.wangcong@gmail.com]
> Sent: Wednesday, October 25, 2017 00:45
> To: netdev@vger.kernel.org
> Cc: Cong Wang <xiyou.wangcong@gmail.com>; Jon Maloy
> <jon.maloy@ericsson.com>; Ying Xue <ying.xue@windriver.com>
> Subject: [Patch net-next] tipc: fix a dangling pointer
>=20
> tsk->group is set to grp earlier, but we forget to unset it
> after grp is freed.
>=20
> Fixes: 75da2163dbb6 ("tipc: introduce communication groups")
> Reported-by: syzkaller bot
> Cc: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/tipc/socket.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c index
> b3b72d8e9543..ea61c32f6b80 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -2756,8 +2756,10 @@ static int tipc_sk_join(struct tipc_sock *tsk, str=
uct
> tipc_group_req *mreq)
>  	seq.upper =3D seq.lower;
>  	tipc_nametbl_build_group(net, grp, mreq->type, domain);
>  	rc =3D tipc_sk_publish(tsk, mreq->scope, &seq);
> -	if (rc)
> +	if (rc) {
>  		tipc_group_delete(net, grp);
> +		tsk->group =3D NULL;
> +	}
>=20
>  	/* Eliminate any risk that a broadcast overtakes the sent JOIN */
>  	tsk->mc_method.rcast =3D true;
> --
> 2.13.0
