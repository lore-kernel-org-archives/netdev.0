From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 2/3] net-next: dsa: add multi cpu port support
Date: Wed, 31 May 2017 02:06:36 +0200
Message-ID: <20170531000636.GA12615@lunn.ch>
References: <20170530104419.6052-1-john@phrozen.org>
 <20170530104419.6052-2-john@phrozen.org>
 <8d6996ef-72c0-546f-6bbe-5a6ea6e83c5f@gmail.com>
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
In-Reply-To: <8d6996ef-72c0-546f-6bbe-5a6ea6e83c5f@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> - past the initial setup, if we start creating bridge devices and so on,
> we have no way to tell: group Ports 0-3 together and send traffic to CPU
> port 0, then let Port 5 alone and send traffic to CPU port 1, that's a
> DSA-only problem though, because we still have the CPU port(s) as
> independent network interfaces.

What is the problem here? Frames come out the master interface, get
untagged and passed to the slave interface and go upto the bridge. It
should all just work. Same in the reverse direction.

In order to make best use of the extra bandwidth of having two cpu
ports, i probably want the user ports reasonably evenly distributed
between the CPU ports. Dedicating one CPU port to one user port is
probably sub-optimal. How many people have 1Gbps Fibre to the home,
which could fully utilise a one-to-one mapping for the WAN port?

> Now, that would still force the user to configure two bridges in order
> to properly steer traffic towards the requested ports but it would allow
> us to be very flexible (which is probably desired here) in how ports are
> grouped together.

We want a sensible default, spreading the slave ports evenly over the
CPU ports. We could add a devlink command to change the defaults at
runtime.

	Andrew
