From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 4/6] net/mlx4_core: Do not BUG_ON during reset when
 PCI is offline
Date: Wed, 17 Feb 2016 11:21:18 +0200
Message-ID: <56C43B8E.2020209@mellanox.com>
References: <1455634911-31206-1-git-send-email-ogerlitz@mellanox.com>
 <1455634911-31206-5-git-send-email-ogerlitz@mellanox.com>
 <56C36AB6.6040707@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Eran Ben Elisha" <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Daniel Jurgens <danielj@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0090.outbound.protection.outlook.com ([157.56.112.90]:9184
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933850AbcBQJ5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 04:57:18 -0500
In-Reply-To: <56C36AB6.6040707@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/2016 8:30 PM, Sergei Shtylyov wrote:
>> --- a/drivers/net/ethernet/mellanox/mlx4/catas.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
>> @@ -182,10 +182,17 @@ void mlx4_enter_error_state(struct 
>> mlx4_dev_persistent *persist)
>>           err = mlx4_reset_slave(dev);
>>       else
>>           err = mlx4_reset_master(dev);
>> -    BUG_ON(err != 0);
>> +
>> +    if (!err)
>> +        mlx4_err(dev, "device was reset successfully\n");
>> +    else
>> +        /* EEH could have disabled the PCI channel during reset. That's
>> +         * recoverable and the PCI error flow will handle it.
>> +         */
>> +        if (!pci_channel_offline(dev->persist->pdev))
>> +            BUG_ON(1);
>
>    I'm afraid this needs {}. 

Hey, don't be afraid just for that, stay cool... we can add that here if 
it helps, as for the blank line not deletedby this patch on which you 
commented later, will not remove it as part of a patch which is a strict 
fix.

Or.
