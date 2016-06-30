From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: bcmsysport: Device stats are unsigned long
Date: Thu, 30 Jun 2016 12:58:47 -0700
Message-ID: <577579F7.4040203@gmail.com>
References: <1467309389-12377-1-git-send-email-f.fainelli@gmail.com>
 <20160630183336.GM7480@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34430 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbcF3T6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 15:58:50 -0400
Received: by mail-pa0-f68.google.com with SMTP id us13so7906188pab.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 12:58:49 -0700 (PDT)
In-Reply-To: <20160630183336.GM7480@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2016 11:33 AM, Andrew Lunn wrote:
> On Thu, Jun 30, 2016 at 10:56:29AM -0700, Florian Fainelli wrote:
>> On 64bits kernels, device stats are 64bits wide, not 32bits.
>>
>> Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/net/ethernet/broadcom/bcmsysport.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
>> index 543bf38105c9..21f21e23e695 100644
>> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
>> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
>> @@ -392,7 +392,11 @@ static void bcm_sysport_get_stats(struct net_device *dev,
>>  		else
>>  			p = (char *)priv;
>>  		p += s->stat_offset;
>> -		data[i] = *(u32 *)p;
> 
> Hi Florian
> 
> Could you not just change this cast from u32 to unsigned long and be
> done?

Seems like this would work yes, even with our mixture of u32 stats read
from HW and the software netdev stats, thanks!
-- 
Florian
