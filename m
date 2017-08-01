From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] net: qcom/emac: add software control for pause frame
 mode
Date: Tue, 1 Aug 2017 17:00:20 -0500
Message-ID: <9e7c0589-d163-a735-bb4c-87bc216164d2@codeaurora.org>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-3-git-send-email-timur@codeaurora.org>
 <293ae5e0-c161-0c00-e40c-2583734aa2d4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:48716 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751938AbdHAWAW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 18:00:22 -0400
In-Reply-To: <293ae5e0-c161-0c00-e40c-2583734aa2d4@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2017 04:51 PM, Florian Fainelli wrote:

> A few adapters (bcmgenet, bcmsysport) support configuring the pause
> quanta so it would not be inconceivable to try to update
> ethtool_pauseparam to include additional fields such as:

Wouldn't this require a change to the user space tool?

> - number of pause frames to send where we define an arbitrary high
> default value (e.g: 0xffff), N < 0xffff is something drivers can test
> for whether they support it, and 0 is only valid if pause is already
> disabled
> 
> - pause quanta (16-bits)
> 
> Private flags are not usually that great and there could be more
> adapters capable of doing the same pause frame number configuration, but
> since there is no available knob it's hard to know.

Well, for the EMAC, the quanta in this case would be either 1 or 
infinite.  For other devices, it could be any combination of values.  In 
a future revision of the hardware, we might support a variable quanta. 
And I suspect that some devices measure the quanta in time, not count.

How would the user know what the acceptable values are?  If I set the 
quanta to 10 via user space, and my driver truncates that to 1, I don't 
think that would be acceptable.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
