From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH net-next 9/9] ldmvsw: disable tso and gso for bridge
 operations
Date: Fri, 3 Feb 2017 13:21:48 -0800
Message-ID: <f8587318-fb76-6711-6546-16839a4a0059@oracle.com>
References: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
 <1486143755-192532-10-git-send-email-shannon.nelson@oracle.com>
 <1486144770.21871.94.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29851 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752506AbdBCVWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:22:20 -0500
In-Reply-To: <1486144770.21871.94.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/3/2017 9:59 AM, Eric Dumazet wrote:
> On Fri, 2017-02-03 at 09:42 -0800, Shannon Nelson wrote:
>> The ldmvsw driver is specifically for supporting the ldom virtual
>> networking by running in the primary ldom and using the LDC to connect
>> the remaining ldoms to the outside world via a bridge.  With TSO and GSO
>> supported while connected the bridge, things tend to misbehave as seen in
>> our case by delayed packets, enough to begin triggering retransmits and
>> affecting overall throughput.  By turning off advertised support for TSO
>> and GSO we restore stable traffic flow through the bridge.
>>
>> Orabug: 23293104
>>
>> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
>> ---
>>  drivers/net/ethernet/sun/ldmvsw.c         |    5 ++---
>>  drivers/net/ethernet/sun/sunvnet_common.c |    3 ++-
>>  2 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
>> index 552c0a9..bd2cfbc 100644
>> --- a/drivers/net/ethernet/sun/ldmvsw.c
>> +++ b/drivers/net/ethernet/sun/ldmvsw.c
>> @@ -299,8 +299,7 @@ static struct net_device *vsw_alloc_netdev(u8 hwaddr[],
>>  	dev->ethtool_ops = &vsw_ethtool_ops;
>>  	dev->watchdog_timeo = VSW_TX_TIMEOUT;
>>
>> -	dev->hw_features = NETIF_F_TSO | NETIF_F_GSO | NETIF_F_GSO_SOFTWARE |
>> -			   NETIF_F_HW_CSUM | NETIF_F_SG;
>> +	dev->hw_features = NETIF_F_HW_CSUM;
>
>
> You also removed NETIF_F_SG

Hmmm - yep, I'll put that back in for the respin.

Thanks,
sln
