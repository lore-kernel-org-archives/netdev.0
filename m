From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: Ethernet: how to disable gigabit support
Date: Sat, 7 Feb 2015 15:35:45 +0100
Message-ID: <20150207153545.6530fce6@neptune.home>
References: <20150205202527.GA7917@amd>
	<54D3F267.3000908@gmail.com>
	<20150206135706.GB25683@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150206135706.GB25683@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 06 February 2015 Pavel Machek wrote:
> On Thu 2015-02-05 14:44:55, Florian Fainelli wrote:
> > On 05/02/15 12:25, Pavel Machek wrote:
> > > This happened on more than one project: there's gigabit-capable chip,
> > > but the connector is not designed for gigabit speed.
> > > 
> > > I'd like to have speed autonegotiation, but not offer gigabit (as it
> > > will not work).
> > > 
> > > Is there way to do that without hacking the kernel? Should mii-tool do
> > > that?
> > 
> > Since you use the PHY library, you should be able to do something like
> > this in your PHY driver prior to starting the PHY state machine:
> > 
> > phydev->supported &= PHY_BASIC_FEATURES (effectively masking Gigabit
> > capability)
> 
> Thanks, that did the trick.
> 								Pavel
> (But still it would be nice to have a generic way of doing this,
> using something like mii-tool.)

You can use ethtool to do so:

  ethtool -s ethX advertise 0x0f

c.f. man ethtool:
  advertise N
    Sets the speed and duplex advertised by autonegotiation. The argument is
    a hexadecimal value using one or a combination of the following values:

      0x001     10 Half
      0x002     10 Full
      0x004     100 Half
      0x008     100 Full
      0x010     1000 Half        (not supported by IEEE standards)
      0x020     1000 Full
      0x8000    2500 Full        (not supported by IEEE standards)
      0x1000    10000 Full
      0x20000   20000MLD2 Full   (not supported by IEEE standards)
      0x40000   20000KR2 Full    (not supported by IEEE standards)

Bruno
