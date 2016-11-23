From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC net-next 0/3] net: bridge: Allow CPU port configuration
Date: Wed, 23 Nov 2016 09:21:42 +0100
Message-ID: <20161123082142.GA1873@nanopsycho>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
 <20161122174140.2ly226dcxkv23nlo@splinter.mtl.com>
 <20161122174829.GD14947@lunn.ch>
 <20161122220859.GF1819@nanopsycho>
 <6e1bce5a-3bc6-ad7b-6cc0-ca80c0f86f55@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, Ido Schimmel <idosch@idosch.org>,
        netdev@vger.kernel.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, stephen@networkplumber.org,
        vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
        idosch@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:36442 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933035AbcKWIVq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 03:21:46 -0500
Received: by mail-wj0-f194.google.com with SMTP id jb2so459976wjb.3
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 00:21:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <6e1bce5a-3bc6-ad7b-6cc0-ca80c0f86f55@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 23, 2016 at 01:24:30AM CET, f.fainelli@gmail.com wrote:
>On 11/22/2016 02:08 PM, Jiri Pirko wrote:
>> Tue, Nov 22, 2016 at 06:48:29PM CET, andrew@lunn.ch wrote:
>>> Hi Ido
>>>
>>>> First of all, I want to be sure that when we say "CPU port", we're
>>>> talking about the same thing. In mlxsw, the CPU port is a pipe between
>>>> the device and the host, through which all packets trapped to the host
>>>> go through. So, when a packet is trapped, the driver reads its Rx
>>>> descriptor, checks through which port it ingressed, resolves its netdev,
>>>> sets skb->dev accordingly and injects it to the Rx path via
>>>> netif_receive_skb(). The CPU port itself isn't represented using a
>>>> netdev.
>>>
>>> With DSA, we have a real physical ethernet network interface for the
>>> 'cpu' port. It connects to one of the ports of the switch. Frames on
>> 
>> Every port should be visible as a netdevice, including cpu port.
>> Would it make sence to have representors for those?
>
>The CPU port is kind of already visible with DSA since you need the
>switch to be attached to a normal Ethernet MAC driver (later referenced
>as eth0 for simplicity). Since eth0 is going to potentially receive/send
>switch tagged traffic, and the model is to terminate the interfaces at
>the port level, this interface does not really have any meaningful use
>from a data exchange, apart from multiplexing/demultiplexing switch tags
>(when enabled).

But this is not the switch port, but the counterpart on the other end of
MII. There should be 2 netdevices, one for each.


>
>If we did create a "cpu" network device, this interface would not be
>able to send/receive traffic either, because the per-port network
>interfaces are terminated at their level, and the conduit interface is
>just used for transmitting/receiving switch tagged traffic. It does have
>value as a controlling interface only though.

In this case, yes.


>
>As a controlling interface, this can be helpful, but we need to decide
>which side of the switch this CPU interface would represent, is it the
>switch's view of the CPU port, or is the Ethernet MAC view's of the
>switch's CPU port, attached to it (especially true with discrete switch
>chips).
>
>If we did use eth0 as a controlling interface, we need to somehow be
>able to overload (in an objected oriented fashioned) the netdev_ops,
>ethtool_ops and switchdev_ops for that interface so as to make it
>participate in the switch configuration (we actually do this already for
>ethtool statistics, but this is ugly).
>-- 
>Florian
