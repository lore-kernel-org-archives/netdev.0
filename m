From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: ep93xx_eth: Do not crash unloading module
Date: Tue, 6 Dec 2016 12:44:21 -0800
Message-ID: <5ba93557-02c0-c337-44c8-8d96fc94cf08@gmail.com>
References: <20161205032205.14127-1-f.fainelli@gmail.com>
 <20161205.153602.1770726597007697695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hsweeten@visionengravers.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34272 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbcLFUpT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 15:45:19 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so20862418pgc.1
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 12:44:23 -0800 (PST)
In-Reply-To: <20161205.153602.1770726597007697695.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2016 12:36 PM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Sun,  4 Dec 2016 19:22:05 -0800
> 
>> When we unload the ep93xx_eth, whether we have opened the network
>> interface or not, we will either hit a kernel paging request error, or a
>> simple NULL pointer de-reference because:
>>
>> - if ep93xx_open has been called, we have created a valid DMA mapping
>>   for ep->descs, when we call ep93xx_stop, we also call
>>   ep93xx_free_buffers, ep->descs now has a stale value
>>
>> - if ep93xx_open has not been called, we have a NULL pointer for
>>   ep->descs, so performing any operation against that address just won't
>>   work
>>
>> Fix this by adding a NULL pointer check for ep->descs which means that
>> ep93xx_free_buffers() was able to successfully tear down the descriptors
>> and free the DMA cookie as well.
>>
>> Fixes: 1d22e05df818 ("[PATCH] Cirrus Logic ep93xx ethernet driver")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Applied, thanks Florian.

Thanks! Can you also queue this one for -stable? The original commit
dates back from 2006, but it should apply with minor hunks to all
-stable kernels.

Cheers
-- 
Florian
