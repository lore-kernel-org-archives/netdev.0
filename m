From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: qcom/emac: add software control for pause frame
 mode
Date: Tue, 1 Aug 2017 15:06:16 -0700
Message-ID: <e48a4be0-18c9-4068-97bd-098715637edd@gmail.com>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-3-git-send-email-timur@codeaurora.org>
 <293ae5e0-c161-0c00-e40c-2583734aa2d4@gmail.com>
 <9e7c0589-d163-a735-bb4c-87bc216164d2@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34772 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752037AbdHAWGT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 18:06:19 -0400
Received: by mail-qk0-f193.google.com with SMTP id q66so2966671qki.1
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 15:06:19 -0700 (PDT)
In-Reply-To: <9e7c0589-d163-a735-bb4c-87bc216164d2@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2017 03:00 PM, Timur Tabi wrote:
> On 08/01/2017 04:51 PM, Florian Fainelli wrote:
> 
>> A few adapters (bcmgenet, bcmsysport) support configuring the pause
>> quanta so it would not be inconceivable to try to update
>> ethtool_pauseparam to include additional fields such as:
> 
> Wouldn't this require a change to the user space tool?

It would yes.

> 
>> - number of pause frames to send where we define an arbitrary high
>> default value (e.g: 0xffff), N < 0xffff is something drivers can test
>> for whether they support it, and 0 is only valid if pause is already
>> disabled
>>
>> - pause quanta (16-bits)
>>
>> Private flags are not usually that great and there could be more
>> adapters capable of doing the same pause frame number configuration, but
>> since there is no available knob it's hard to know.
> 
> Well, for the EMAC, the quanta in this case would be either 1 or
> infinite.  For other devices, it could be any combination of values.  In
> a future revision of the hardware, we might support a variable quanta.
> And I suspect that some devices measure the quanta in time, not count.

OK, either way is fine and there should be ways to convert back and
forth without too much trouble.

> 
> How would the user know what the acceptable values are?  If I set the
> quanta to 10 via user space, and my driver truncates that to 1, I don't
> think that would be acceptable.

There can be several ways to deal with that, we can either ask for a
strict rejection before committing the changes to the HW, or we can have
the HW round up/down to the nearest supported values and an user would
call get_pauseparam() to see which value ended-up being used.

Anyway food for thought, David decides what gets merged ;)
-- 
Florian
