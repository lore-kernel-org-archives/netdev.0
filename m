From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Tue, 1 Aug 2017 15:08:42 -0700
Message-ID: <2117a00e-b2a3-a767-aee0-5f25b59facb9@gmail.com>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <1af0df70-c8a9-f327-abba-9c977c4dfdc9@gmail.com>
 <ec4dedc0-d117-4fa7-9226-1aba61bf2e7e@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36719 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752012AbdHAWIp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 18:08:45 -0400
Received: by mail-qt0-f193.google.com with SMTP id c15so2979001qta.3
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 15:08:45 -0700 (PDT)
In-Reply-To: <ec4dedc0-d117-4fa7-9226-1aba61bf2e7e@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2017 03:02 PM, Timur Tabi wrote:
> On 08/01/2017 04:55 PM, Florian Fainelli wrote:
>> This is not specific to your EMAC, a lot of adapters have this problem
>> actually.
>>
>> I wonder if it would make sense to reach for a broader solution where we
>> could have a networking stack panic/oops notifier which will actively
>> clean up the active network devices' RX queue(s) and if tx_pause was
>> enabled, disable it. We could have drivers announce themselves as
>> needing this either via NETIF_F_* feature bit or some other private flag.
> 
> Unfortunately, the problem occurs only when Linux hangs, to the point
> where the driver's interrupt handlers are blocked.  The RX queue is 256
> entries, and the processor has 48 cores, so the EMAC is never going to
> send pause frames in any real-world situation.
> 
> The only time I've seen pause frames sent out is in the lab when I halt
> the cores with a hardware debugger, and only if I have enough network
> traffic that the EMAC picks up.

The size and scale of your system makes it so but imagine e.g: a single
core ~ 1Ghz @ 1Gbits/sec system having the same problems, here you are
quite likely to see the system under panic flooding the network.

Then again your patch is fine and can be revised at any time a broader
facility is offered, I just felt like we actually have a good way with
reasonably driver-agnostic code to possibly deal with that problem.

Implementing such a solution would not be a -stable backport candidate
though....
-- 
Florian
