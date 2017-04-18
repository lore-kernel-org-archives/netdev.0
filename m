From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] smsc95xx: Use skb_cow to deal with cloned skbs
Date: Tue, 18 Apr 2017 10:23:32 -0700
Message-ID: <1492536212.10587.133.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170418144857.7810-1-james.hughes@raspberrypi.org>
         <1492530711.10587.125.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170418.115546.921863837348166438.davem@davemloft.net>
         <CAE_XsMJZGPvENhCgyvuz48PyLk=T7L-tGoktzVBLPPYDP7oR8A@mail.gmail.com>
         <1492534347.10587.130.camel@edumazet-glaptop3.roam.corp.google.com>
         <eb8f4cda-d1b1-1038-513b-08ef016042ae@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: James Hughes <james.hughes@raspberrypi.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34808 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753042AbdDRRXe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:23:34 -0400
Received: by mail-pf0-f195.google.com with SMTP id g23so16906757pfj.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:23:34 -0700 (PDT)
In-Reply-To: <eb8f4cda-d1b1-1038-513b-08ef016042ae@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-18 at 10:10 -0700, Florian Fainelli wrote:

> BTW, this pattern of using skb_headroom() ... skb_copy_expand() seems to
> be recurring in pretty much all USB network drivers that have a tx_fixup
> callback set. The problem is that each driver needs its own
> headroom/tailroom so the fix is not as simple as putting the
> skb_cow_head() before the call to the drivers' tx_fixup...
> 
> I wonder if a coccinelle patch would be able to do that for us?

Not sure about coccinelle, because some drivers also need some tailroom.
