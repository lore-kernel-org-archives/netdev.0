From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [ethtool] ethtool: Remove UDP Fragmentation Offload use from
 ethtool
Date: Tue, 29 Aug 2017 10:50:20 +0300
Message-ID: <a1c55136-c534-bcdf-ccc8-3f38affb69e8@mellanox.com>
References: <1503923928-9419-1-git-send-email-tariqt@mellanox.com>
 <1503932411.11498.67.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170828182251.GC3092@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Shaker Daibes <shakerd@mellanox.com>
To: "John W. Linville" <linville@tuxdriver.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0080.outbound.protection.outlook.com ([104.47.1.80]:21216
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750779AbdH2Hu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 03:50:29 -0400
In-Reply-To: <20170828182251.GC3092@tuxdriver.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 28/08/2017 9:22 PM, John W. Linville wrote:
> On Mon, Aug 28, 2017 at 08:00:11AM -0700, Eric Dumazet wrote:
>> On Mon, 2017-08-28 at 15:38 +0300, Tariq Toukan wrote:
>>> From: Shaker Daibes <shakerd@mellanox.com>
>>>
>>> UFO was removed in kernel, here we remove it in ethtool app.
>>>
>>> Fixes the following issue:
>>> Features for ens8:
>>> Cannot get device udp-fragmentation-offload settings: Operation not supported
>>>
>>> Tested with "make check"
>>>
>>> Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
>>> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
>>> ---
>>
>>
>> Hi guys
>>
>> I would rather remove the warning, but leave the ability to switch UFO
>> on machines running old kernel but a recent ethtool.
>>
>> ethtool does not need to be downgraded every time we boot an old
>> kernel ;)

Thanks all for your quick replies.

We thought about the backward compatibility issue before getting to 
writing this patch.
But, as the feature has very few device support, and is not that useful,
we thought it would be best to just totally remove it from ethtool.

We can re-work this so the feature would still be available on old kernels.

But I wonder how the warning removal should be done??

I have some suggestions in mind:
1) Have a special condition that does not print a warning only in the 
case of UFO?
2) Remove the warning totally? I don't like this option.
3) Add a max_kernel_ver field in struct off_flag_def, and use it to not 
print the warning, or to mark the feature 'off [fixed]'.

Please let me know what you think.

> 
> No, definitely not.
>   
>> Thanks !
> 
> Tariq, will you be reworking this as Eric suggests?

Yes. Once we decide what is the correct way to keep it backward compatible.

> 
> John
> 

Regards,
Tariq Toukan
