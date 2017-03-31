From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 9/9] net: dsa: mv88e6xxx: add cross-chip
 bridging
Date: Fri, 31 Mar 2017 19:09:41 +0200
Message-ID: <20170331170941.GL12814@lunn.ch>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
 <20170330213715.9666-10-vivien.didelot@savoirfairelinux.com>
 <20170331163949.GI12814@lunn.ch>
 <87d1cxqtco.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87d1cxqtco.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 31, 2017 at 12:55:03PM -0400, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > On Thu, Mar 30, 2017 at 05:37:15PM -0400, Vivien Didelot wrote:
> >> Implement the DSA cross-chip bridging operations by remapping the local
> >> ports an external source port can egress frames to, when this cross-chip
> >> port joins or leaves a bridge.
> >> 
> >> The PVT is no longer configured with all ones allowing any external
> >> frame to egress any local port. Only DSA and CPU ports, as well as
> >> bridge group members, can egress frames on local ports.
> >
> > With the ZII devel B, we have two switches with PVT, and one
> > without. What happens in this setup? Can the non-PVT switch leak
> > frames out user ports which should otherwise be blocked?
> 
> If CONFIG_BRIDGE_VLAN_FILTERING isn't enabled in the kernel, the non-PVT
> switch would indeed have no mean to restrict arbitrary external
> frames. So in that setup, yes the switch can theorically leak frames.

I don't like the idea of leaking frames. It has security implications,
and hard to debug weird networking problems, like some other machine
is using my IP address, maybe spanning tree is broken if BPDUs leak,
even broadcast storms?

So we need to consider the complexity of detecting we have a non-PVT
destination switch, and forward it frames via the software bridge.

What about the case the non-PVT switch is in the middle of a chain of
PVT switches?

Maybe to start with, to keep it simple, we check all switches are PVT
capable. If they are not, we refuse to use PVT and all inter-switch
frames need to go via the Linux software bridge?

       Andrew
