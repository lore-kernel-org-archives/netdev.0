From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next RFC 04/12] net: dsa: Add ordered workqueue
Date: Thu, 06 Jul 2017 14:45:01 -0400
Message-ID: <87lgo1cslu.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com> <1499268990-19251-5-git-send-email-arkadis@mellanox.com> <6db9cee1-8f2c-e086-55e6-d70b69c3824e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53462 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751765AbdGFSrc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 14:47:32 -0400
In-Reply-To: <6db9cee1-8f2c-e086-55e6-d70b69c3824e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arkadi,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 07/05/2017 08:36 AM, Arkadi Sharshevsky wrote:
>> This workqueue will be used for FDB add/del processing. It should
>> be destroyed after all devices unregistered successfully.
>> 
>> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
>> ---
>>  include/net/dsa.h |  1 +
>>  net/dsa/dsa.c     | 13 +++++++++++++
>>  2 files changed, 14 insertions(+)
>> 
>> diff --git a/include/net/dsa.h b/include/net/dsa.h
>> index f054d41..4835b0e 100644
>> --- a/include/net/dsa.h
>> +++ b/include/net/dsa.h
>> @@ -451,6 +451,7 @@ void unregister_switch_driver(struct dsa_switch_driver *type);
>>  struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
>>  
>>  struct net_device *dsa_dev_to_net_device(struct device *dev);
>> +bool dsa_schedule_work(struct work_struct *work);
>
> I'd move this to dsa_priv.h in net/dsa/ because it is not supposed to be
> used by DSA drivers.
>
> You may also consider squashing this into the next patch since in itself
> it's not used just yet.

I agree with Florian on this. Even though it'll make the next patch a
bit bigger, it'll make it easier to understand the whole workqueue
processing logic.

Thanks,

        Vivien
