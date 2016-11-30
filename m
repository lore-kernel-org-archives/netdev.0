From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 21:43:34 +0100
Message-ID: <20161130204334.GC1864@nanopsycho.orion>
References: <1480495831.3563.135.camel@infinera.com>
 <20161130135257.GC18716@lunn.ch>
 <1480516241.3563.142.camel@infinera.com>
 <20161130152503.GE21645@lunn.ch>
 <1480523716.3563.144.camel@infinera.com>
 <20161130165500.GH21645@lunn.ch>
 <1480527852.3563.146.camel@infinera.com>
 <20161130180927.GK21645@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f174.google.com ([209.85.210.174]:35576 "EHLO
        mail-wj0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754688AbcK3Unx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 15:43:53 -0500
Received: by mail-wj0-f174.google.com with SMTP id v7so186515569wjy.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 12:43:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161130180927.GK21645@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 30, 2016 at 07:09:27PM CET, andrew@lunn.ch wrote:
>> Something like that. I need to run routing protocols on the switch I/Fs and egress
>> pkgs on selected switch I/Fs bypassing ARP, just like DSA does with its vendor
>> tags.
>
>Does the switch have an equivalent tagging protocol? If you are
>building a tree of switches you need something like this for frames
>going from the host via intermediate switches and out a specific port
>on a remote switch.
>
>> We might have a tree as well so now I really wonder: Given we write a
>> proper switchdev driver, can it support switchtrees without touching
>> switchdev infra structure?
>
>Jiri Pirko <jiri@resnulli.us> is probably the best person to ask about
>this. DSA hides the knowledge that there is multiple switches. To
>switchdev, a tree of switches looks like one switch. This is not
>because of switchdev, it is just the existing DSA code worked when
>switchdev came along.

Looks like the hw is DSA-ish. If I'm not mistaken about that, should be
handled as a part of DSA.


>
> If not I guess we will attach a physical
>> eth I/F to the switch and use both DSA and switchdev to support both trees
>> and HW offload. 
>
>This only works if the switch has the necessary tagging protocol to
>pass through multiple switches.
>
>> We have on an existing board with a BCM ROBO switch with lots of ports(>24),
>> managed over SPI. Looking at BCM DSA tag code it looks like it only supports
>> some 8 ports or so. I still have to find out if this is a limitation in BCM tagging
>> protocol or if just not impl. in DSA yet.
>
>Hi Florian, care to comment?
>
>As far as i understand, the tag used for SF2 and B53 does not support
>a tree of switches. But the big ROBO switches might have a different
>tagging protocol.
>
>  Andrew
