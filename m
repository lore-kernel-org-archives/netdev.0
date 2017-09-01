From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next 0/8] net: dsa: Multi-queue awareness
Date: Fri, 1 Sep 2017 02:05:02 +0200
Message-ID: <20170901000502.GB28960@lunn.ch>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us, jhs@mojatatu.com,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47640 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751242AbdIAAFF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 20:05:05 -0400
Content-Disposition: inline
In-Reply-To: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 05:18:44PM -0700, Florian Fainelli wrote:
> This patch series is sent as reference, especially because the last patch
> is trying not to be creating too many layer violations, but clearly there
> are a little bit being created here anyways.
> 
> Essentially what I am trying to achieve is that you have a stacked device which
> is multi-queue aware, that applications will be using, and for which they can
> control the queue selection (using mq) the way they want. Each of each stacked
> network devices are created for each port of the switch (this is what DSA
> does). When a skb is submitted from say net_device X, we can derive its port
> number and look at the queue_mapping value to determine which port of the
> switch and queue we should be sending this to. The information is embedded in a
> tag (4 bytes) and is used by the switch to steer the transmission.
> 
> These stacked devices will actually transmit using a "master" or conduit
> network device which has a number of queues as well. In one version of the
> hardware that I work with, we have up to 4 ports, each with 8 queues, and the
> master device has a total of 32 hardware queues, so a 1:1 mapping is easy. With
> another version of the hardware, same number of ports and queues, but only 16
> hardware queues, so only a 2:1 mapping is possible.
> 
> In order for congestion information to work properly, I need to establish a
> mapping, preferably before transmission starts (but reconfiguration while
> interfaces are running would be possible too) between these stacked device's
> queue and the conduit interface's queue.
> 
> Comments, flames, rotten tomatoes, anything!

Right, i think i understand.

This works just for traffic between the host and ports.  The host can
set the egress queue. And i assume the queues are priorities, either
absolute or weighted round robin, etc.

But this has no effect on traffic going from port to port. At some
point, i expect you will want to offload TC for that.

How will the two interact? Could the TC rules also act on traffic from
the host to a port? Would it be simpler in the long run to just
implement TC rules?

	  Andrew
