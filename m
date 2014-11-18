From: Wengang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] [bonding]: clear header_ops when last slave detached
Date: Tue, 18 Nov 2014 09:56:22 +0800
Message-ID: <546AA746.8090008@oracle.com>
References: <1415845156-15461-1-git-send-email-wen.gang.wang@oracle.com> <54694D09.4080304@oracle.com> <866.1416274729@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44976 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbaKRByn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 20:54:43 -0500
In-Reply-To: <866.1416274729@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

=E4=BA=8E 2014=E5=B9=B411=E6=9C=8818=E6=97=A5 09:38, Jay Vosburgh =E5=86=
=99=E9=81=93:
> Wengang <wen.gang.wang@oracle.com> wrote:
>
>> Hi,
>>
>> Could anybody please review this patch?
> 	I don't see that the original of this ever came through netdev.

Oh, that' bad. I sent this to netdev@vger.kernel.org. The mail address=20
is wrong?

>> thanks,
>> wengang
>>
>> =E4=BA=8E 2014=E5=B9=B411=E6=9C=8813=E6=97=A5 10:19, Wengang Wang =E5=
=86=99=E9=81=93:
>>> When last slave of a bonding master is removed, the bonding then do=
es not work.
>>> When packet_snd is called against with a master net_device, it acce=
sses
>>> header_ops. In case the header_ops is not valid any longer(say modu=
le unloaded)
>>> it will then access an invalid memory address.
>>> This patch try to fix this issue by clearing header_ops when last s=
lave
>>> detached.
> 	Am I correct in presuming that this behavior is limited to ipoib
> slaves only?  I don't see that this could occur with ethernet slaves,=
 as
> eth_header_ops isn't part of a module.  This needs to be mentioned in
> the commit log.
Yes, the problem is found with ipoib slaves.
>>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>>> ---
>>>    drivers/net/bonding/bond_main.c | 2 ++
>>>    1 file changed, 2 insertions(+)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/=
bond_main.c
>>> index c9ac06c..84a34fc 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -1728,6 +1728,8 @@ static int __bond_release_one(struct net_devi=
ce *bond_dev,
>>>    	unblock_netpoll_tx();
>>>    	synchronize_rcu();
>>>    	bond->slave_cnt--;
>>> +	if (!bond->slave_cnt)
>>> +		bond->dev->header_ops =3D NULL;
>>>      	if (!bond_has_slaves(bond)) {
>>>    		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
> 	I believe your addition could be moved into the block for the
> next if, as "!bond->slave_cnt" is essentially "!bond_has_slaves()".

Yes, Agree.
I will send the second prompt soon with commit message mentioning ipoib=
=2E

thanks,
wengang

> 	-J
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
