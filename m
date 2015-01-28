From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] caif: remove wrong dev_net_set() call
Date: Wed, 28 Jan 2015 16:07:02 +0100
Message-ID: <54C8FB16.6040006@6wind.com>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com> <1422307694-10079-2-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, arvid.brodin@alten.se, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org,
	Dmitry Tarnyagin <abi.dmitryt@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:45881 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716AbbA1U2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:28:44 -0500
Received: by mail-wi0-f180.google.com with SMTP id h11so15033081wiw.1
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 12:28:43 -0800 (PST)
In-Reply-To: <1422307694-10079-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing bouncing email addresses (dmitry.tarnyagin@lockless.no and
sjur.brandeland@stericsson.com)
CC: Dmitry Tarnyagin <abi.dmitryt@gmail.com>

Dmitry, please also have a look to
http://permalink.gmane.org/gmane.linux.network/347942


Thank you,
Nicolas

Le 26/01/2015 22:28, Nicolas Dichtel a =C3=A9crit :
> src_net points to the netns where the netlink message has been receiv=
ed. This
> netns may be different from the netns where the interface is created =
(because
> the user may add IFLA_NET_NS_[PID|FD]). In this case, src_net is the =
link netns.
>
> It seems wrong to override the netns in the newlink() handler because=
 if it
> was not already src_net, it means that the user explicitly asks to cr=
eate the
> netdevice in another netns.
>
> CC: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
> CC: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
> Fixes: 8391c4aab1aa ("caif: Bugfixes in CAIF netdevice for close and =
flow control")
> Fixes: c41254006377 ("caif-hsi: Add rtnl support")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>   drivers/net/caif/caif_hsi.c | 1 -
>   net/caif/chnl_net.c         | 1 -
>   2 files changed, 2 deletions(-)
>
> diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.=
c
> index 5e40a8b68cbe..b3b922adc0e4 100644
> --- a/drivers/net/caif/caif_hsi.c
> +++ b/drivers/net/caif/caif_hsi.c
> @@ -1415,7 +1415,6 @@ static int caif_hsi_newlink(struct net *src_net=
, struct net_device *dev,
>
>   	cfhsi =3D netdev_priv(dev);
>   	cfhsi_netlink_parms(data, cfhsi);
> -	dev_net_set(cfhsi->ndev, src_net);
>
>   	get_ops =3D symbol_get(cfhsi_get_ops);
>   	if (!get_ops) {
> diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
> index 4589ff67bfa9..67a4a36febd1 100644
> --- a/net/caif/chnl_net.c
> +++ b/net/caif/chnl_net.c
> @@ -470,7 +470,6 @@ static int ipcaif_newlink(struct net *src_net, st=
ruct net_device *dev,
>   	ASSERT_RTNL();
>   	caifdev =3D netdev_priv(dev);
>   	caif_netlink_parms(data, &caifdev->conn_req);
> -	dev_net_set(caifdev->netdev, src_net);
>
>   	ret =3D register_netdevice(dev);
>   	if (ret)
>
