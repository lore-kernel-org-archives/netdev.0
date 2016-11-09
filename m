From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sfc: enable 4-tuple UDP RSS hashing
Date: Wed, 09 Nov 2016 13:59:36 -0500 (EST)
Message-ID: <20161109.135936.1665492542584983522.davem@davemloft.net>
References: <2c97d90b-bbb3-2cdc-7a72-597fd3f5231a@solarflare.com>
        <20161109.130918.1657511488354824947.davem@davemloft.net>
        <2932a4dc-cee0-47d1-d4a9-2b293e6155ad@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39322 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754077AbcKIS7h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:59:37 -0500
In-Reply-To: <2932a4dc-cee0-47d1-d4a9-2b293e6155ad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 9 Nov 2016 18:51:15 +0000

> On 09/11/16 18:09, David Miller wrote:
>> From: Edward Cree <ecree@solarflare.com>
>> Date: Tue, 8 Nov 2016 13:02:05 +0000
>>
>>> On 07/11/16 18:20, David Miller wrote:
>>>> From: Edward Cree <ecree@solarflare.com>
>>>> Date: Thu, 3 Nov 2016 22:10:31 +0000
>>>>
>>>>> EF10 based NICs have configurable RSS hash fields, and can be made to take the
>>>>> ports into the hash on UDP (they already do so for TCP).  This patch series
>>>>> enables this, in order to improve spreading of UDP traffic.
>>>> What does the chip do with fragmented traffic?
>>> Only the first fragment will be considered UDP, it will treat the rest as "other
>>> IP" and 2-tuple hash them, probably hitting a different queue.
>>>
>>> My understanding is that while that will reduce performance, that shouldn't be a
>>> problem as performance-sensitive users will avoid fragmentation anyway.
>>> It could also lead to out-of-order packet delivery, but it's UDP so that's
>>> supposed to be OK.
>> Our software hashing never tries to inspect the ports for fragmented
>> frames.  And I'm pretty sure this is intentional.
>>
>> We should minimize the difference between what we do in software, which
>> we fully control, and what we ask the hardware to offload for us.
>>
>> If you can't configure the chip to skip the ports for fragmented frames
>> than I'm going to ask you to drop this.
> I just checked and it turns out I was mistaken, we don't treat the first fragment
> differently after all, we skip the ports for all fragments including the first.
> Sorry for the misinformation.

That's more in line with what is expected, series applied, thanks.
