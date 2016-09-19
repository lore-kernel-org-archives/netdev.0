From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v10 0/3] return offloaded stats as default and
 expose original sw stats
Date: Mon, 19 Sep 2016 00:56:46 -0400 (EDT)
Message-ID: <20160919.005646.2094585553294775889.davem@davemloft.net>
References: <1474031138-2065-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52970 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbcISE47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 00:56:59 -0400
In-Reply-To: <1474031138-2065-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 16 Sep 2016 15:05:35 +0200

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
 ...

Series applied, thanks Jiri.
