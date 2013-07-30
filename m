From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 1/3] of: provide a binding for the 'fixed-link'
 property
Date: Tue, 30 Jul 2013 16:28:24 +0100
Message-ID: <20130730152824.GB29859@e106331-lin.cambridge.arm.com>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130723112259.GE4833@e106331-lin.cambridge.arm.com>
 <20130730111604.76fd5b6e@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devicetree-discuss@lists.ozlabs.org" <devicetree-discuss@lists.ozlabs.org>,
 "rob.herring@calxeda.com" <rob.herring@calxeda.com>,
 Florian Fainelli <florian@openwrt.org>,
 Grant Likely <grant.likely@secretlab.ca>,
 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20130730111604.76fd5b6e@skate>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Thomas,

On Tue, Jul 30, 2013 at 10:16:04AM +0100, Thomas Petazzoni wrote:
> Dear Mark Rutland,
> 
> On Tue, 23 Jul 2013 12:22:59 +0100, Mark Rutland wrote:
> 
> > > +Some Ethernet MACs have a "fixed link", and are not connected to a
> > > +normal MDIO-managed PHY device. For those situations, a Device Tree
> > > +binding allows to describe a "fixed link".
> > 
> > Are partictular MACs fixed link, or can some either be either fixed link
> > or wired to an MDIO-managed PHY? i.e. can we assume a given MAC is
> > fixed-link from its compatible string?
> 
> No, you can't. The case that I have is that the mvneta Ethernet MAC
> (of Marvell 370/XP SOCs) is sometimes used with a MDIO-managed PHY, and
> sometimes used with a switch that isn't manageable at all and should be
> considered as a fixed link.
> 
> So no, the compatible string of the Ethernet MAC cannot be used to
> determine whether we're wired fixed link or to a classical MDIO-managed
> PHY.

Ok. Thanks for the info.

> 
> > > +Such a fixed link situation is described within an Ethernet device
> > > +Device Tree node using a 'fixed-link' property, composed of 5
> > > +elements:
> > 
> > I'm not sure grouping these values together is the best way of handling
> > this. It's rather opaque, and inflexible for future extension.
> 
> That's the DT binding that has been used by PowerPC platforms since
> several years, and I've simply re-used it. See 'git grep fixed-link
> arch/powerpc/boot/dts'.
> 
> I have nothing against creating another DT binding, but for a start, I
> thought using existing bindings would be the best idea.

Sorry, I was not aware that was the case. I agree that reusing the
existing binding is the right place to start.

> 
> > > + 1. A fake PHY ID, which must be unique accross all fixed-link PHYs in
> > > +    the system.
> > 
> > Is there any reason this couldn't be allocated dynamically within the
> > kernel as needed? I don't see why an arbitrary unique value should be a
> > dt binding requirement; it seems like a leak of Linux implementation
> > details.
> 
> As I pointed out in my reply to Grant, this value is used both as the
> PHY address on the fake fixed MDIO bus, and as the PHY identifier as
> reported by MII registers PHYS_ID1 and PHYS_ID2. If we can get assigned
> a proper PHY identifier that is used statically by the driver (it
> doesn't have to be different per fixed PHY instance), then we can
> allocate the PHY address dynamically. It requires a little bit of API
> changes but that's certainly doable. See my reply to Grant for a
> proposal about this.

Ok. I must admit to not knowing enough about ethernet hardware to fully
understand the implications here for the MII registers, but otherwise
your proposal makes sense.

> 
> > > + 2. The duplex (1 for full-duplex, 0 for half-duplex)
> > 
> > Will this change for a given MAC?
> > 
> > Could we not have a boolean property for each of these, and require one
> > to be present?
> > 
> > Possibly fixed-link-full-duplex / fix-link-half-duplex?
> > 
> > > + 3. The speed (10, 100, 1000)
> > 
> > fixed-link-speed?
> > 
> > > + 4. The pause setting (1 for enabled, 0 for disabled)
> > > + 5. The asym pause setting (1 for enabled, 0 for disabled)
> > 
> > Boolean properties for both of these?
> 
> As Florian already answered, he already proposed something like this in
> the past, and it was rejected because a fixed PHY is not a piece of
> hardware and should therefore not be represented in the Device Tree.
> However, the fact that the MAC is not connected to a MDIO-manageable
> PHY but to some fixed-link thing is a property of the MAC hardware
> layout, and can therefore be expressed as a property of the MAC
> hardware.

I think it would certainly make sense to describe this as a property of
the MAC.

Thanks,
Mark.

> 
> See the thread that starts at
> http://article.gmane.org/gmane.linux.network/275771, and specifically
> Grant answers to Florian suggestions of having DT nodes to represent
> fixed PHY: http://article.gmane.org/gmane.linux.network/276208. Grant's
> answer was:
> 
> """
> I think this discussion is going in the wrong direction. The concept
> of a dummy phy is really a Linux kernel internal detail. Creating some
> kind of dummy MDIO bus node does not describe the hardware. There is
> already support in the kernel for Ethernet MACs connected directly to
> a switch or other device. It is far better to describe how the MAC
> needs to be configured than to invent a non-existent phy. Search for
> "fixed-link" in the kernel tree to see how it is used.
> """
> 
> Best regards,
> 
> Thomas
> -- 
> Thomas Petazzoni, Free Electrons
> Kernel, drivers, real-time and embedded Linux
> development, consulting, training and support.
> http://free-electrons.com
> 
