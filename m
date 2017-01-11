From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: switchdev: Avoid sleep in atomic
 with DSA
Date: Tue, 10 Jan 2017 20:26:24 -0500 (EST)
Message-ID: <20170110.202624.599513931685652148.davem@davemloft.net>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
        <20170109204849.GA28310@splinter>
        <e28f29c8-04ed-1d71-7b13-27a5d58d111c@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: idosch@idosch.org, netdev@vger.kernel.org,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        jiri@resnulli.us
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33790 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754822AbdAKB00 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:26:26 -0500
In-Reply-To: <e28f29c8-04ed-1d71-7b13-27a5d58d111c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 9 Jan 2017 12:56:48 -0800

> On 01/09/2017 12:48 PM, Ido Schimmel wrote:
>> Hi Florian,
>> 
>> On Mon, Jan 09, 2017 at 11:44:59AM -0800, Florian Fainelli wrote:
>>> Hi all,
>>>
>>> This patch series is to resolve a sleeping function called in atomic context
>>> debug splat that we observe with DSA.
>>>
>>> Let me know what you think, I was also wondering if we should just always
>>> make switchdev_port_vlan_fill() set SWITCHDEV_F_DEFER, but was afraid this
>>> could cause invalid contexts to be used for rocker, mlxsw, i40e etc.
>> 
>> Isn't this a bit of overkill? All the drivers you mention fill the VLAN
>> dump from their cache and don't require sleeping. Even b53 that you
>> mention in the last patch does that, but reads the PVID from the device,
>> which entails taking a mutex.
> 
> Correct.
> 
>> 
>> Can't you just cache the PVID as well? I think this will solve your
>> problem. Didn't look too much into the b53 code, so maybe I'm missing
>> something. Seems that mv88e6xxx has a similar problem.
> 
> I suppose we could indeed cache the PVID for b53, but for mv88e6xxx it
> seems like we need to perform a bunch of VTU operations, and those
> access HW registers, Andrew, Vivien, how do you want to solve that, do
> we want to introduce a general VLAN cache somewhere in switchdev/DSA/driver?

I would definitely prefer to see cached state used instead of this deferred
operation stuff.
