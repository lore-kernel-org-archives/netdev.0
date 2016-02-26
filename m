From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 03/12] net-next: mediatek: add embedded switch driver
 (ESW)
Date: Fri, 26 Feb 2016 18:29:49 +0100
Message-ID: <20160226172949.GF12022@lunn.ch>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
 <1456496504-50429-4-git-send-email-blogic@openwrt.org>
 <20160226151813.GD12022@lunn.ch>
 <56D07C82.2040204@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Crispin <blogic@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	Matthias Brugger <matthias.bgg@gmail.com>,
	"Steven Liu (?????????)" <steven.liu@mediatek.com>,
	"Carlos Huang (?????????)" <Carlos.Huang@mediatek.com>,
	"Fred Chang (?????????)" <Fred.Chang@mediatek.com>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56D07C82.2040204@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 26, 2016 at 05:25:38PM +0100, Felix Fietkau wrote:
> On 2016-02-26 16:18, Andrew Lunn wrote:
> > On Fri, Feb 26, 2016 at 03:21:35PM +0100, John Crispin wrote:
> >> The ESW is found in many of the old 100mbit MIPS based SoCs. it has 5
> >> external ports, 1 cpu port and 1 further port that the internal HW
> >> offloading engine connects to.
> >> 
> >> This driver is very basic and only provides basic init and irq support.
> >> The SoC and switch core both have support for a special tag making DSA
> >> support possible.
> > 
> > Hi Crispin
> > 
> > There was recently a discussion about adding switches without using
> > DSA or switchdev. It was pretty much decided we would not accept such
> > drivers.
> For exactly this reason, the code does not provide any non-standard API
> for allowing the user to configure the switch. The hardware needs to be
> programmed with some defaults for the driver to be functional (since the
> switch logic is built into the SoC).
>
> 
> In my opinion, leaving this part out does not make much sense and
> neither does deferring the entire patch series until we have a
> switchdev/DSA capable driver. This is just a starting point, which will
> be turned into a proper driver with the right APIs later.

You are however introducing APIs which become things you need to
support. Your device tree binding for example. The device tree
maintainers consider this a stable API you need to maintain forever.
Can you guarantee that you can maintain this binding, and also support
the DSA binding? How messy is it going to make your code supporting
two bindings?

You currently have one netdev interface for five switch ports. When
you have a DSA driver, you have 5 additional netdev interfaces, one
per port, and your original interface is now unusable. Isn't that an
API change.

You need to find incremental steps towards a switchdev/DSA driver
which are not going to hinder you in the long run.

    Andrew
