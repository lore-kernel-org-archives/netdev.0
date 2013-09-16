From: Willy Tarreau <w@1wt.eu>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Mon, 16 Sep 2013 19:45:14 +0200
Message-ID: <20130916174514.GF3188@1wt.eu>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com>
 <20130915205701.5c61a444@skate> <20130916065047.GH27487@1wt.eu>
 <20130916175152.4e013457@skate>
 <20130916162209.GL12758@n2100.arm.linux.org.uk>
 <20130916182450.639084c6@skate>
 <20130916171416.GM12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 netdev@vger.kernel.org, Ethan Tuttle <ethan@ethantuttle.com>,
 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 Gregory =?iso-8859-1?Q?Cl=E9ment?= <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20130916171416.GM12758@n2100.arm.linux.org.uk>
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

On Mon, Sep 16, 2013 at 06:14:16PM +0100, Russell King - ARM Linux wrote:
> On Mon, Sep 16, 2013 at 06:24:50PM +0200, Thomas Petazzoni wrote:
> > Could this be caused by bitflips in the RAM due to bad timings, or
> > overheating or that kind of things?
> =

> Well, the SoC is an Armada 370, which uses Marvell's own Sheeva core.
> From what I understand, this is a CPU designed entirely by Marvell, so
> the interpretation of these codes may not be correct.  This is made
> harder to diagnose in that Marvell is soo secret with their
> documentation; indeed for this CPU there is no information publically
> available (there's only the product briefs).

Yes and their salesmen never respond after many attempts in more than one
year now. Looks like they want to keep their chips for themselves only :-(

> Bad timings could certainly cause bitflips, as could poor routing of
> data line D8 (eg, incorrect termination or routing causing reflections
> on the data line - remember that with modern hardware, almost every
> signal is a transmission line).

This board has a really clean routing and placement, chips are very close.
That does not rule out the possibility of a lacking termination, but it
would probably affect more users.

> Marginal or noisy power supplies could also be a problem - for example,
> if the impedance of the power supply connections is too great, it may
> work with some patterns of use but not others.

We have some margin here, I measured less than 1 Amp to boot and something
like 6-700 mA in idle if my memory serves me correctly. The 3A PSU and its
thicker-than-average wires seem safe. I think that Globalscale learned a
lot from the horrible Guruplug design that all this part needs to be done
correctly and they did a very clean job this time.

> There's soo many possibilities...

Including faulty components. I'm not aware of an equivalent of cpuburn for
ARM, it would probably help, though it's probably harder to design in a
generic way than on x86 where all systems are the same.

> However, if the fault codes above really do equate to what's in the ARMv7
> Architecture Reference Manual, I think we can rule out the routing and
> RAM chips - because a cache parity error points to bit flips in the cache,
> or if there is no cache parity checking implemented, it means something
> is corrupting the state of the SoC - which could be due to bad power
> supplies.
> =

> How do we get to the bottom of this?  That's a very good question - one
> which is going to be very difficult to solve.  Ideally, it means working
> with the manufacturer's design team to try and work out what's going on
> at the board level, probably using logic analysers to capture the bus
> activity leading up to the failure.  Also, checking the power supplies
> at the SoC too - checking that they're within correct tolerance and
> checking the amount of noise on them.
> =

> I think all we can do at the moment is to wait for further reports to roll
> in and see whether a better pattern emerges.

Especially since there are also some heavy testers who don't seem to be
impacted :-/

> If you want to try something - and you suspect it may be heat related,
> you could try putting the board inside a container, monitor the temperatu=
re
> inside the container, and put it in your freezer!  Just be careful of the
> temperature of the other devices on the board getting too cold though -
> remember, most consumer electronics is only rated for an *operating*
> temperature range of 0=B0C to 70=B0C and your freezer will be something l=
ike
> -20=B0C - so don't let the ambient temperature inside the container go
> below 0=B0C!  If the CPU is producing lots of heat though, it may keep the
> container sufficiently warm that that's not a problem.  The theory is
> that by making the ambient 15 to 20=B0C cooler, you will also lower the
> temperature of the hotter parts by a similar amount.

Sometimes you can also do the opposite, heat it gently with an hair dryer
while working to see if problems happen moore frequently. It's often easier
to do than working in a cold place as you don't have issues with the wires,
and it does not accumulate moist.

I've detected some early failures this way ; the NAND in my Iomega Iconnect
is extremely sensitive to heating to the point that I had to stick a heat
sink on it and take the board out of its case to avoid hangs. The hair
dryer quickly revealed the culprit in a few minutes when it took weeks to
get a failure before.

Willy
