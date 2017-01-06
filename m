From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] arm: dts: vf610-zii-dev-rev-b: remove ports
 label
Date: Fri, 6 Jan 2017 23:41:27 +0100
Message-ID: <20170106224127.GD10626@lunn.ch>
References: <20170106220043.21280-1-vivien.didelot@savoirfairelinux.com>
 <20170106220043.21280-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170106220043.21280-3-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 06, 2017 at 05:00:43PM -0500, Vivien Didelot wrote:
> Now that the "label" property is optional for Ethernet switch ports,
> remove them in the ZII Dev Rev B board DTS.
>
> On a Rev B board, once eth1 is up, this DTS now exposes to userspace:
> 
>     # ip link | grep ': ' | cut -d: -f2
>      lo
>      eth0
>      eth1
>      eth2@eth1
>      eth3@eth1
>      eth4@eth1
>      eth5@eth1
>      eth6@eth1
>      eth7@eth1
>      eth8@eth1
>      eth9@eth1
>      eth10@eth1
>      eth11@eth1
>      eth12@eth1

It exposes this, this time. Next time, it could be:

      eth0
      eth1@eth0
      eth2@eth0
      eth3@eth0
      eth4@eth0
      eth5@eth0
      eth6@eth0
      eth7@eth0
      eth8@eth0
      eth9@eth0
      eth10@eth0
      eth11@eth0
      eth12

depending on how the base interfaces enumerate.

We have gone from deterministic names to non-deterministic names for
the switch ports. We now must have udev rules, if we want
deterministic names.

If the names where not deterministic before, i would of agreed to
this. But they are deterministic, set by device tree, and set to match
some physical property of the hardware, generally the label on the
case/PCB.

If somebody were to produce a switch on a PCIe card, or a USB bus,
things then are non-deterministic, and leaving the kernel to assign a
name is O.K. So i think the first patch is O.K, but i don't like this
patch.

	Andrew
