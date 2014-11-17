From: Wengang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] [bonding]: clear header_ops when last slave detached
Date: Mon, 17 Nov 2014 09:19:05 +0800
Message-ID: <54694D09.4080304@oracle.com>
References: <1415845156-15461-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wengang Wang <wen.gang.wang@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36274 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbaKQBRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 20:17:22 -0500
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id sAH1HL1V023683
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 01:17:22 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id sAH1HKAq024149
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 01:17:21 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userz7022.oracle.com (8.14.5+Sun/8.14.4) with ESMTP id sAH1HJcY005791
	for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 01:17:20 GMT
In-Reply-To: <1415845156-15461-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Could anybody please review this patch?

thanks,
wengang

=E4=BA=8E 2014=E5=B9=B411=E6=9C=8813=E6=97=A5 10:19, Wengang Wang =E5=86=
=99=E9=81=93:
> When last slave of a bonding master is removed, the bonding then does=
 not work.
> When packet_snd is called against with a master net_device, it access=
es
> header_ops. In case the header_ops is not valid any longer(say module=
 unloaded)
> it will then access an invalid memory address.
> This patch try to fix this issue by clearing header_ops when last sla=
ve
> detached.
>
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> ---
>   drivers/net/bonding/bond_main.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index c9ac06c..84a34fc 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1728,6 +1728,8 @@ static int __bond_release_one(struct net_device=
 *bond_dev,
>   	unblock_netpoll_tx();
>   	synchronize_rcu();
>   	bond->slave_cnt--;
> +	if (!bond->slave_cnt)
> +		bond->dev->header_ops =3D NULL;
>  =20
>   	if (!bond_has_slaves(bond)) {
>   		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
