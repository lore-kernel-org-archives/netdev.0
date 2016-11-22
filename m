From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC net-next 0/3] net: bridge: Allow CPU port configuration
Date: Tue, 22 Nov 2016 23:08:59 +0100
Message-ID: <20161122220859.GF1819@nanopsycho>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
 <20161122174140.2ly226dcxkv23nlo@splinter.mtl.com>
 <20161122174829.GD14947@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@idosch.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, stephen@networkplumber.org,
        vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
        idosch@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:35253 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933012AbcKVWJC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 17:09:02 -0500
Received: by mail-wj0-f195.google.com with SMTP id f8so7405513wje.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 14:09:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161122174829.GD14947@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 22, 2016 at 06:48:29PM CET, andrew@lunn.ch wrote:
>Hi Ido
> 
>> First of all, I want to be sure that when we say "CPU port", we're
>> talking about the same thing. In mlxsw, the CPU port is a pipe between
>> the device and the host, through which all packets trapped to the host
>> go through. So, when a packet is trapped, the driver reads its Rx
>> descriptor, checks through which port it ingressed, resolves its netdev,
>> sets skb->dev accordingly and injects it to the Rx path via
>> netif_receive_skb(). The CPU port itself isn't represented using a
>> netdev.
>
>With DSA, we have a real physical ethernet network interface for the
>'cpu' port. It connects to one of the ports of the switch. Frames on

Every port should be visible as a netdevice, including cpu port.
Would it make sence to have representors for those?

>this interface have an extra header, indicating which switch port it
>came from, and we do a similar resolving it to a slave netdev, strip
>of the header and injecting it into the receiver path via
>netif_receive_skb().
>
>	Andrew
