From: David Arcari <darcari@redhat.com>
Subject: Re: [PATCH v2] net: ethernet: aquantia: set net_device mtu when mtu
 is changed
Date: Mon, 13 Mar 2017 16:30:52 -0400
Message-ID: <d2b95877-b6f9-8919-c0ea-880022607c6b@redhat.com>
References: <1489093426-25733-1-git-send-email-darcari@redhat.com>
 <285b77bc-f7d1-9ad6-1bc6-639f13ff9b83@gmx.de> <58C2BC9B.6040907@redhat.com>
 <279a67c4-a27a-e3b6-08b5-0e0a12abbbde@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Pavel Belous <pavel.belous@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58716 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752601AbdCMUax (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 16:30:53 -0400
In-Reply-To: <279a67c4-a27a-e3b6-08b5-0e0a12abbbde@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2017 04:19 PM, Pavel Belous wrote:
> 
> 
> On 10.03.2017 17:47, David Arcari wrote:
>> Hi,
>>
>> On 03/09/2017 05:43 PM, Lino Sanfilippo wrote:
>>> Hi,
>>>
>>> On 09.03.2017 22:03, David Arcari wrote:
>>>> When the aquantia device mtu is changed the net_device structure is not
>>>> updated.  As a result the ip command does not properly reflect the mtu change.
>>>>
>>>> Commit 5513e16421cb incorrectly assumed that __dev_set_mtu() was making the
>>>> assignment ndev->mtu = new_mtu;  This is not true in the case where the driver
>>>> has a ndo_change_mtu routine.
>>>>
>>>> Fixes: 5513e16421cb ("net: ethernet: aquantia: Fixes for aq_ndev_change_mtu")
>>>>
>>>> v2: no longer close/open net-device after mtu change
>>>>
>>>> Cc: Pavel Belous <Pavel.Belous@aquantia.com>
>>>> Signed-off-by: David Arcari <darcari@redhat.com>
>>>> ---
>>>>  drivers/net/ethernet/aquantia/atlantic/aq_main.c | 10 ++--------
>>>>  1 file changed, 2 insertions(+), 8 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
>>>> b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
>>>> index dad6362..bba5ebd 100644
>>>> --- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
>>>> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
>>>> @@ -96,15 +96,9 @@ static int aq_ndev_change_mtu(struct net_device *ndev,
>>>> int new_mtu)
>>>>      struct aq_nic_s *aq_nic = netdev_priv(ndev);
>>>>      int err = aq_nic_set_mtu(aq_nic, new_mtu + ETH_HLEN);
>>>>
>>>> -    if (err < 0)
>>>> -        goto err_exit;
>>>> +    if (!err)
>>>> +        ndev->mtu = new_mtu;
>>>>
>>>> -    if (netif_running(ndev)) {
>>>> -        aq_ndev_close(ndev);
>>>> -        aq_ndev_open(ndev);
>>>> -    }
>>>> -
>>>> -err_exit:
>>>
>>> Removing the restart has nothing to do with the bug you want to fix here, has
>>> it?
>>> I suggest to send a separate patch for this.
>>>
>>> Regards,
>>> Lino
>>>
>>
>> I'm fine with that.  Pavel does that work for you?
>>
>> It would mean that the original version of this patch should be applied and
>> either you or I could send the follow-up patch.
>>
>> Best,
>>
>> -Dave
>>
> 
> David,
> 
> Yes, I think for this it is better to make separate patch.
> I can prepare a patch for "close/open netdev" myself.
> 
> Probably you need send the original version of this patch as "v3" (I'm no sure
> what it is possible to discard v2 and apply v1 instead.)
> 
> Thank you,
> Pavel

Please drop v2 of this patch.  We would like to have v1 applied.

Thanks,

-Dave
