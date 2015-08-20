From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH] netcp:Fix error checking in the function gbe_open
Date: Thu, 20 Aug 2015 18:05:16 -0400
Message-ID: <55D64F1C.3070509@ti.com>
References: <1438280850-9613-1-git-send-email-xerofoify@gmail.com> <55BA7EA3.9020204@ti.com> <55CCB713.8000406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: nick <xerofoify@gmail.com>, <w-kwok2@ti.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55CCB713.8000406@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/13/2015 11:26 AM, nick wrote:
>
>
> On 2015-07-30 03:44 PM, Murali Karicheri wrote:
>> On 07/30/2015 02:27 PM, Nicholas Krause wrote:
>>> This fixes error checking in the function gbe_open by checking if
>>> the function netcp_register_txhook has failed by returning a error
>>> code and if so jump to the goto label fail for handling internal
>>> failures in this function.
>>>
>>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>>> ---
>>>    drivers/net/ethernet/ti/netcp_ethss.c | 6 ++++--
>>>    1 file changed, 4 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
>>> index 9b7e0a3..e81e66b 100644
>>> --- a/drivers/net/ethernet/ti/netcp_ethss.c
>>> +++ b/drivers/net/ethernet/ti/netcp_ethss.c
>>> @@ -2257,8 +2257,10 @@ static int gbe_open(void *intf_priv, struct net_device *ndev)
>>>        if (ret)
>>>            goto fail;
>>>
>>> -    netcp_register_txhook(netcp, GBE_TXHOOK_ORDER, gbe_tx_hook,
>>> -                  gbe_intf);
>>> +    ret = netcp_register_txhook(netcp, GBE_TXHOOK_ORDER, gbe_tx_hook,
>>> +                    gbe_intf);
>>> +    if (ret)
>>> +        goto fail;
>>>
>>>        slave->open = true;
>>>        netcp_ethss_update_link_state(gbe_dev, slave, ndev);
>>>
>> Acked-by: Murali Karicheri <m-karicheri2@ti.com>
>>
> Murali,
> I was wondering if this patch is being merged as I haven't seen in move into David's network
> tree with the merged of your driver's tree.
> Nick
>
>
Nick,

Not sure what else I need to do to get it applied to net repo.

David,

Can this be applied to net/master ?

Thanks

-- 
Murali Karicheri
Linux Kernel, Keystone
