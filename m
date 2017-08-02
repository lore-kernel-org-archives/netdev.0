From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 2 Aug 2017 13:23:18 -0500
Message-ID: <290fdd25-7e05-57c8-8f89-52bb3bae1e59@codeaurora.org>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <20170802.105453.1408822174555343968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53430 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752285AbdHBSXV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 14:23:21 -0400
In-Reply-To: <20170802.105453.1408822174555343968.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2017 12:54 PM, David Miller wrote:
> And if this kind of thing matters to the user, they will have a
> software or hardware watchdog driver enabled to break out of this
> situation.

The problem is that the user is not going to expect that the EMAC can 
disable the nearby switch(es) when the kernel is hung and not rebooted 
quickly enough.  Internally, this bug/feature has caused quite a bit of 
mayhem, so the problem is real.  No cares about enabling flow control -- 
it just happens to be enabled on some systems where the switch agrees to 
it.  So random individuals can't debug the hardware because suddenly the 
EMAC has gone haywire and disabled the local network.

> Turning off flow control by default has so many negative ramifications
> and don't try to convince me that users will be "aware" of this and
> turn it back on.

What are the negative ramifications?  It's practically impossible to 
overload the chip such that it can't process the incoming packets fast 
enough.  I don't know of any real-world situation where the EMAC needs 
to transmit pause frames.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
