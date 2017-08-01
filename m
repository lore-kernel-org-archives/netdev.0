From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Tue, 1 Aug 2017 17:02:44 -0500
Message-ID: <ec4dedc0-d117-4fa7-9226-1aba61bf2e7e@codeaurora.org>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <1af0df70-c8a9-f327-abba-9c977c4dfdc9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52432 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752012AbdHAWCq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 18:02:46 -0400
In-Reply-To: <1af0df70-c8a9-f327-abba-9c977c4dfdc9@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2017 04:55 PM, Florian Fainelli wrote:
> This is not specific to your EMAC, a lot of adapters have this problem
> actually.
> 
> I wonder if it would make sense to reach for a broader solution where we
> could have a networking stack panic/oops notifier which will actively
> clean up the active network devices' RX queue(s) and if tx_pause was
> enabled, disable it. We could have drivers announce themselves as
> needing this either via NETIF_F_* feature bit or some other private flag.

Unfortunately, the problem occurs only when Linux hangs, to the point 
where the driver's interrupt handlers are blocked.  The RX queue is 256 
entries, and the processor has 48 cores, so the EMAC is never going to 
send pause frames in any real-world situation.

The only time I've seen pause frames sent out is in the lab when I halt 
the cores with a hardware debugger, and only if I have enough network 
traffic that the EMAC picks up.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
