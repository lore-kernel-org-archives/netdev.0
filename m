From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [ethtool] ethtool: Remove UDP Fragmentation Offload use from
 ethtool
Date: Mon, 4 Sep 2017 14:46:48 +0300
Message-ID: <06dd9133-7a55-20ae-5097-bdb1b5825f25@mellanox.com>
References: <1503923928-9419-1-git-send-email-tariqt@mellanox.com>
 <1503932411.11498.67.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170828182251.GC3092@tuxdriver.com>
 <a1c55136-c534-bcdf-ccc8-3f38affb69e8@mellanox.com>
 <20170829104452.b6n5ikxxioib7766@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Shaker Daibes <shakerd@mellanox.com>
To: Michal Kubecek <mkubecek@suse.cz>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20066.outbound.protection.outlook.com ([40.107.2.66]:59473
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753477AbdIDLq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 07:46:57 -0400
In-Reply-To: <20170829104452.b6n5ikxxioib7766@unicorn.suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 29/08/2017 1:44 PM, Michal Kubecek wrote:
> On Tue, Aug 29, 2017 at 10:50:20AM +0300, Tariq Toukan wrote:
>> On 28/08/2017 9:22 PM, John W. Linville wrote:
>>> On Mon, Aug 28, 2017 at 08:00:11AM -0700, Eric Dumazet wrote:
>>>> On Mon, 2017-08-28 at 15:38 +0300, Tariq Toukan wrote:
>>>>> From: Shaker Daibes <shakerd@mellanox.com>
>>>>>
>>>>> UFO was removed in kernel, here we remove it in ethtool app.
>>>>>
>>>>> Fixes the following issue:
>>>>> Features for ens8:
>>>>> Cannot get device udp-fragmentation-offload settings: Operation not supported
>>
>> But I wonder how the warning removal should be done??
>>
>> I have some suggestions in mind:
>> 1) Have a special condition that does not print a warning only in the case
>> of UFO?
>> 2) Remove the warning totally? I don't like this option.
>> 3) Add a max_kernel_ver field in struct off_flag_def, and use it to not
>> print the warning, or to mark the feature 'off [fixed]'.
> 
> IMHO there is nothing wrong with not writing a warning for "get"
> operation, after all it's just "ethtool -k", i.e. "show me all
> offloading flags" and we do not warn about unsupported named features
> either. IMHO the only question should be how friendly we should be to
> old scripts expecting the line in the output:
> 
>    (a) omit the "udp-fragmentation-offload:" line (be consistent)
>    (b) say something like "udp-fragmentation-offload: n/a"
>    (c) pretend it's there and is off (most careful but misleading)
> 
> Personally, I would prefer (a) but some badly written scripts might have
> problem with this approach.
> 
Thanks Michal.
I think we'll go for some variation of (a), omitting the warning.
Here we can choose to limit the omission for this exact case, i.e. only 
when offload is UFO and err is "Operation not supported".

> On the other hand, an attempt to _set_ the flag with "ethtool -K" should
> issue an error.
> 
> Michal Kubecek
> 
