From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 0/4] net: switchdev: Avoid sleep in atomic with
 DSA
Date: Mon, 9 Jan 2017 23:29:03 +0200
Message-ID: <20170109212903.GA12125@splinter>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
 <20170109204849.GA28310@splinter>
 <e28f29c8-04ed-1d71-7b13-27a5d58d111c@gmail.com>
 <20170109211436.GB28310@splinter>
 <20170109212320.GB20958@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:40863 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755902AbdAIV3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:29:30 -0500
Content-Disposition: inline
In-Reply-To: <20170109212320.GB20958@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 10:23:20PM +0100, Andrew Lunn wrote:
> > Truth be told, I don't quite understand why switchdev infra even tries
> > to dump the VLANs from the device. Like, in which situations is this
> > going to be different from what the software bridge reports?
> 
> What happens when the hardware is out of resources and says sorry,
> cannot do that. There has been a few discussions about what to do in
> that situation. Fall back to software, i.e. the software bridge does
> it, or totally fail the operation. If you are failing back to
> software, the states can be different.

If the driver fails to set its VLAN filters then the operation is also
rollbacked in the software bridge, in which case you're still in sync.
