From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next 0/8] net: dsa: Multi-queue awareness
Date: Fri, 1 Sep 2017 20:50:12 +0200
Message-ID: <20170901185012.GA8122@lunn.ch>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
 <20170901000502.GB28960@lunn.ch>
 <7d738ef5-c312-e0b3-3605-1f31fa7dc019@gmail.com>
 <20170901132921.GV22289@lunn.ch>
 <a0b9ab3a-45d8-3371-901b-2249a26b9192@gmail.com>
 <20170901175529.GA1249@lunn.ch>
 <abc112cc-7ac5-d65f-d1b2-136cff4de92d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, jhs@mojatatu.com, netdev@vger.kernel.org,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50132 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752118AbdIASuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 14:50:16 -0400
Content-Disposition: inline
In-Reply-To: <abc112cc-7ac5-d65f-d1b2-136cff4de92d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 01, 2017 at 11:27:43AM -0700, Florian Fainelli wrote:
> On 09/01/2017 10:55 AM, Andrew Lunn wrote:
> > Hi Florian
> > 
> >>>> tc bind dev sw0p0 queue 0 dev eth0 queue 16
> > 
> > It this the eth0 i don't like here. Why not in the implementation just
> > use something like netdev_master_upper_dev_get('sw0p0')? Or does
> 
> Last I brought this up with Jiri that we should link DSA network devices
> to their master network deviecs with netdev_upper_dev_link() he said
> this was not appropriate for DSA slave network devices, but I can't
> remember why, I would assume that any stacked device set up would do that.

There is some form a linking going, our device names show that:

9: lan5@eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default qlen 1000
    link/ether da:87:2a:03:cf:16 brd ff:ff:ff:ff:ff:ff

> In any case, we need to establish a mapping so we have to specify at
> least the target device's queue number. It is quite similar in premise
> to e.g: enslaving a network device to a bridge port:
> 
> ip link set dev eth0 master br0

But here br0 is absolutely required, we have to say which bridge the
slave port should be a member of.

But what good is eth0 in

tc bind dev sw0p0 queue 0 dev eth0 queue 16

As i said suggesting, you have to somehow verify that eth0 is the
conduit interface sw0p0 is using. Which makes the parameter pointless.
Determine it from the sw0p0 somehow.

	  Andrew
