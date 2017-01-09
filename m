From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/4] net: switchdev: Avoid sleep in atomic with DSA
Date: Mon, 09 Jan 2017 16:19:16 -0500
Message-ID: <877f64aq3v.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170109194503.10713-1-f.fainelli@gmail.com> <20170109204849.GA28310@splinter> <e28f29c8-04ed-1d71-7b13-27a5d58d111c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        jiri@resnulli.us
To: Florian Fainelli <f.fainelli@gmail.com>,
        Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44896 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755462AbdAIVTi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:19:38 -0500
In-Reply-To: <e28f29c8-04ed-1d71-7b13-27a5d58d111c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian, Ido,

Florian Fainelli <f.fainelli@gmail.com> writes:

>> Can't you just cache the PVID as well? I think this will solve your
>> problem. Didn't look too much into the b53 code, so maybe I'm missing
>> something. Seems that mv88e6xxx has a similar problem.
>
> I suppose we could indeed cache the PVID for b53, but for mv88e6xxx it
> seems like we need to perform a bunch of VTU operations, and those
> access HW registers, Andrew, Vivien, how do you want to solve that, do
> we want to introduce a general VLAN cache somewhere in switchdev/DSA/driver?

Yes mv88e6xxx does read the hardware registers to get the port default
VID and read the hardware VLAN table.

DSA drivers should be dumb and simply implement switch operations. If
caching is required, it must be implemented in the DSA layer. Since
switchdev is stateless, I hardly see a way to implement it there.

Thanks,

        Vivien
