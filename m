From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 0/4] net: switchdev: Avoid sleep in atomic with
 DSA
Date: Mon, 9 Jan 2017 22:48:49 +0200
Message-ID: <20170109204849.GA28310@splinter>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        jiri@resnulli.us
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:42357 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751249AbdAIUtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:49:16 -0500
Content-Disposition: inline
In-Reply-To: <20170109194503.10713-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Mon, Jan 09, 2017 at 11:44:59AM -0800, Florian Fainelli wrote:
> Hi all,
> 
> This patch series is to resolve a sleeping function called in atomic context
> debug splat that we observe with DSA.
> 
> Let me know what you think, I was also wondering if we should just always
> make switchdev_port_vlan_fill() set SWITCHDEV_F_DEFER, but was afraid this
> could cause invalid contexts to be used for rocker, mlxsw, i40e etc.

Isn't this a bit of overkill? All the drivers you mention fill the VLAN
dump from their cache and don't require sleeping. Even b53 that you
mention in the last patch does that, but reads the PVID from the device,
which entails taking a mutex.

Can't you just cache the PVID as well? I think this will solve your
problem. Didn't look too much into the b53 code, so maybe I'm missing
something. Seems that mv88e6xxx has a similar problem.

Thanks!
