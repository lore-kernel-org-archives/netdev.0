From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 2/3] net-next: dsa: add multi cpu port support
Date: Wed, 31 May 2017 02:52:42 +0200
Message-ID: <20170531005242.GB12615@lunn.ch>
References: <20170530104419.6052-1-john@phrozen.org>
 <20170530104419.6052-2-john@phrozen.org>
 <8d6996ef-72c0-546f-6bbe-5a6ea6e83c5f@gmail.com>
 <20170531000636.GA12615@lunn.ch>
 <881bf3fe-1ffb-b9fd-c844-da265f71370d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, jiri@resnulli.us,
        idosch@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <881bf3fe-1ffb-b9fd-c844-da265f71370d@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 05:16:27PM -0700, Florian Fainelli wrote:
> On 05/30/2017 05:06 PM, Andrew Lunn wrote:
> >> - past the initial setup, if we start creating bridge devices and so on,
> >> we have no way to tell: group Ports 0-3 together and send traffic to CPU
> >> port 0, then let Port 5 alone and send traffic to CPU port 1, that's a
> >> DSA-only problem though, because we still have the CPU port(s) as
> >> independent network interfaces.
> > 
> > What is the problem here? Frames come out the master interface, get
> > untagged and passed to the slave interface and go upto the bridge. It
> > should all just work. Same in the reverse direction.
> 
> The problem is really that is you have multiple CPU ports, how do you
> define which one gets all the traffic by default? Ascending order of
> port number? Descending order?

I would probably default to round robin when allocating user ports to
CPU ports. That probably gives you the best default.

> I actually tend to think that most use cases our there are in the order
> of dedicating one CPU port to one corresponding switch port (user
> facing, or internal) in order to provided guaranteed bandwidth for that
> port.

Which is generally a waste of bandwidth. Best case, i get 40Mbps
Internet access. Meaning 960Mbps of a dedicated cpu port would be
wasted.

>  But as an user, I want to choose how the grouping is going to
> work, and right now, I cannot, unless this is hardcoded in Device Tree,
> which sounds both wrong and inadequate.

So how about round-robin default, and then devlink to move a user port
to a specific cpu port?

We also need to watch out for asymmetry. I think newer marvell chips
don't support egress to multiple CPU ports. Ingress to the switch i
think is unlimited. The older chips are more flexible in this
respect. So we need some degree of flexibility here.
 
	Andrew
