From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC net-next 0/8] net: dsa: Multi-queue awareness
Date: Fri, 1 Sep 2017 11:27:43 -0700
Message-ID: <abc112cc-7ac5-d65f-d1b2-136cff4de92d@gmail.com>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
 <20170901000502.GB28960@lunn.ch>
 <7d738ef5-c312-e0b3-3605-1f31fa7dc019@gmail.com>
 <20170901132921.GV22289@lunn.ch>
 <a0b9ab3a-45d8-3371-901b-2249a26b9192@gmail.com>
 <20170901175529.GA1249@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:35636 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752170AbdIAS14 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 14:27:56 -0400
Received: by mail-wr0-f172.google.com with SMTP id y15so2493468wrc.2
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 11:27:55 -0700 (PDT)
In-Reply-To: <20170901175529.GA1249@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2017 10:55 AM, Andrew Lunn wrote:
> Hi Florian
> 
>>>> tc bind dev sw0p0 queue 0 dev eth0 queue 16
> 
> It this the eth0 i don't like here. Why not in the implementation just
> use something like netdev_master_upper_dev_get('sw0p0')? Or does
> 
> tc bind dev sw0p0 queue 0 dev lo queue 16
> 
> make sense?

Last I brought this up with Jiri that we should link DSA network devices
to their master network deviecs with netdev_upper_dev_link() he said
this was not appropriate for DSA slave network devices, but I can't
remember why, I would assume that any stacked device set up would do that.

In any case, we need to establish a mapping so we have to specify at
least the target device's queue number. It is quite similar in premise
to e.g: enslaving a network device to a bridge port:

ip link set dev eth0 master br0

Thanks
-- 
Florian
