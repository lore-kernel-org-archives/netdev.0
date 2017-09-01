From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next 0/8] net: dsa: Multi-queue awareness
Date: Fri, 1 Sep 2017 15:29:21 +0200
Message-ID: <20170901132921.GV22289@lunn.ch>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
 <20170901000502.GB28960@lunn.ch>
 <7d738ef5-c312-e0b3-3605-1f31fa7dc019@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, jhs@mojatatu.com, netdev@vger.kernel.org,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49318 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752391AbdIAN30 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 09:29:26 -0400
Content-Disposition: inline
In-Reply-To: <7d738ef5-c312-e0b3-3605-1f31fa7dc019@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I suppose that you could somehow use TC to influence how the traffic
> from host to CPU works, but without a "CPU" port representor the
> question is how do we get that done? If we used "eth0" we need to
> callback into the switch driver for programming..

We need to compare how the different switches work with respect to
QoS. Marvell switches do a lot of the classification on the ingress
port where it determines what queue the frame should be placed in on
the egress port. The egress port then schedules its queues.

This does not map to TC too well.

> Regarding the last patch in this series, what I would ideally to replace
> it with is something along the lines of:
> 
> tc bind dev sw0p0 queue 0 dev eth0 queue 16

Why do you need this? sw0p0 has 8 queues? So i assume you use TC on
sw0p0 to place frames into these queues? The queue then gets passed
transparently down through the conduit interface and then used by the
tagger. I don't see why you need eth0 here? We try our best to avoid
eth0 wherever possible, it causes confusion. So i would prefer not to
have to use eth0 with TC commands.

     Andrew
