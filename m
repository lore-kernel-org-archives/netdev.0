From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v8 0/3] return offloaded stats as default and
 expose original sw stats
Date: Thu, 08 Sep 2016 19:21:30 -0700
Message-ID: <57D21CAA.7090605@cumulusnetworks.com>
References: <1473315593-2078-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36522 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbcIICWC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 22:22:02 -0400
Received: by mail-pa0-f44.google.com with SMTP id id6so23105965pad.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 19:21:33 -0700 (PDT)
In-Reply-To: <1473315593-2078-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/7/16, 11:19 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> The problem we try to handle is about offloaded forwarded packets
> which are not seen by kernel. Let me try to draw it:
>
>     port1                       port2 (HW stats are counted here)
>       \                          /
>        \                        /
>         \                      /
>          --(A)---- ASIC --(B)--
>                     |
>                    (C)
>                     |
>                    CPU (SW stats are counted here)
>
>
> Now we have couple of flows for TX and RX (direction does not matter here):
>
> 1) port1->A->ASIC->C->CPU
>
>    For this flow, HW and SW stats are equal.
>
> 2) port1->A->ASIC->C->CPU->C->ASIC->B->port2
>
>    For this flow, HW and SW stats are equal.
>
> 3) port1->A->ASIC->B->port2
>
>    For this flow, SW stats are 0.
>
> The purpose of this patchset is to provide facility for user to
> find out the difference between flows 1+2 and 3. In other words, user
> will be able to see the statistics for the slow-path (through kernel).
>
> Also note that HW stats are what someone calls "accumulated" stats.
> Every packet counted by SW is also counted by HW. Not the other way around.
>
> As a default the accumulated stats (HW) will be exposed to user
> so the userspace apps can react properly.
>
> This patchset add the SW stats (flows 1+2) under offload related stats, so
> in the future we can expose other offload related stat in a similar way.
>

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

thanks.
