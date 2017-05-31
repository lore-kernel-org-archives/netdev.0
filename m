From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 2/3] net-next: dsa: add multi cpu port support
Date: Tue, 30 May 2017 17:16:27 -0700
Message-ID: <881bf3fe-1ffb-b9fd-c844-da265f71370d@gmail.com>
References: <20170530104419.6052-1-john@phrozen.org>
 <20170530104419.6052-2-john@phrozen.org>
 <8d6996ef-72c0-546f-6bbe-5a6ea6e83c5f@gmail.com>
 <20170531000636.GA12615@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, jiri@resnulli.us,
        idosch@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35359 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdEaAQd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:16:33 -0400
In-Reply-To: <20170531000636.GA12615@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2017 05:06 PM, Andrew Lunn wrote:
>> - past the initial setup, if we start creating bridge devices and so on,
>> we have no way to tell: group Ports 0-3 together and send traffic to CPU
>> port 0, then let Port 5 alone and send traffic to CPU port 1, that's a
>> DSA-only problem though, because we still have the CPU port(s) as
>> independent network interfaces.
> 
> What is the problem here? Frames come out the master interface, get
> untagged and passed to the slave interface and go upto the bridge. It
> should all just work. Same in the reverse direction.

The problem is really that is you have multiple CPU ports, how do you
define which one gets all the traffic by default? Ascending order of
port number? Descending order?

> 
> In order to make best use of the extra bandwidth of having two cpu
> ports, i probably want the user ports reasonably evenly distributed
> between the CPU ports. Dedicating one CPU port to one user port is
> probably sub-optimal. How many people have 1Gbps Fibre to the home,
> which could fully utilise a one-to-one mapping for the WAN port?

I actually tend to think that most use cases our there are in the order
of dedicating one CPU port to one corresponding switch port (user
facing, or internal) in order to provided guaranteed bandwidth for that
port. But as an user, I want to choose how the grouping is going to
work, and right now, I cannot, unless this is hardcoded in Device Tree,
which sounds both wrong and inadequate.

> 
>> Now, that would still force the user to configure two bridges in order
>> to properly steer traffic towards the requested ports but it would allow
>> us to be very flexible (which is probably desired here) in how ports are
>> grouped together.
> 
> We want a sensible default, spreading the slave ports evenly over the
> CPU ports. We could add a devlink command to change the defaults at
> runtime.

Sensible default is fine for the first time boot, but we should let
users be entirely flexible in how they want their user-facing ports to
map to a CPU port as you say, and IMHO using separate bridges to
configure that is a possible way to go since there is already knowledge
in the bridge join/leave code in DSA that already knows the
dwnstream/user-facing ports, but does not yet know about CPU ports.

Code speaks better, so let me see if I can cook something to illustrate
this.

Thanks!
-- 
Florian
