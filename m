From: David Arcari <darcari@redhat.com>
Subject: Re: [PATCH] net: ethernet: aquantia: set net_device mtu when mtu is
 changed
Date: Thu, 9 Mar 2017 15:01:49 -0500
Message-ID: <6f6ad527-8664-0cdb-2b3d-b79179b8a7a8@redhat.com>
References: <1489008801-120389-1-git-send-email-darcari@redhat.com>
 <bdf4795a-ad8f-f48e-0861-24ce5700a5ee@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Pavel Belous <pavel.belous@aquantia.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57698 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751009AbdCIUCN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 15:02:13 -0500
In-Reply-To: <bdf4795a-ad8f-f48e-0861-24ce5700a5ee@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2017 02:02 PM, Pavel Belous wrote:
> 
> 
> On 09.03.2017 00:33, David Arcari wrote:
>> When the aquantia device mtu is changed the net_device structure is not
>> updated.  As a result the ip command does not properly reflect the mtu change.
>>
>> Commit 5513e16421cb incorrectly assumed that __dev_set_mtu() was making the
>> assignment ndev->mtu = new_mtu;  This is not true in the case where the driver
>> has a ndo_change_mtu routine.
>>
>> Fixes: 5513e16421cb ("net: ethernet: aquantia: Fixes for aq_ndev_change_mtu")
>>
>> Cc: Pavel Belous <Pavel.Belous@aquantia.com>
>> Signed-off-by: David Arcari <darcari@redhat.com>
>> ---
>>  drivers/net/ethernet/aquantia/atlantic/aq_main.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
>> b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
>> index dad6362..d05fbfd 100644
>> --- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
>> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
>> @@ -98,6 +98,7 @@ static int aq_ndev_change_mtu(struct net_device *ndev, int
>> new_mtu)
>>
>>      if (err < 0)
>>          goto err_exit;
>> +    ndev->mtu = new_mtu;
>>
>>      if (netif_running(ndev)) {
>>          aq_ndev_close(ndev);
>>
> 
> Thank you, David.
> 
> I think we should also remove closing/opening net-device after mtu changed.

Hi Pavel,

I'll go ahead and submit v2.

Thanks,

-Dave

> 
> Regards,
> Pavel
