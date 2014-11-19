From: Wengang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Wed, 19 Nov 2014 13:22:07 +0800
Message-ID: <546C28FF.7060507@oracle.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31640 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbaKSFUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 00:20:48 -0500
In-Reply-To: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay and Eric,

Could you please review the 2nd prompt?

thanks,
wengang

=E4=BA=8E 2014=E5=B9=B411=E6=9C=8819=E6=97=A5 13:18, Wengang Wang =E5=86=
=99=E9=81=93:
> When last slave of a bonding master is removed, the bonding then does=
 not work.
> When packet_snd is called against with a master net_device, it access=
es
> header_ops. In case the header_ops is not valid any longer(say ipoib =
module
> unloaded), it will then access an invalid memory address.
> This patch try to fix this issue by clearing header_ops when last sla=
ve
> detached.
>
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> ---
>   drivers/net/bonding/bond_main.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index c9ac06c..52a7e4b 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1730,6 +1730,7 @@ static int __bond_release_one(struct net_device=
 *bond_dev,
>   	bond->slave_cnt--;
>  =20
>   	if (!bond_has_slaves(bond)) {
> +		bond->dev->header_ops =3D NULL;
>   		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
>   		call_netdevice_notifiers(NETDEV_RELEASE, bond->dev);
>   	}
