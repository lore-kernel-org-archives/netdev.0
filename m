From: Amit Kucheria <amit.kucheria@nokia.com>
Subject: Re: [RFC] Runtime power management on ipw2100
Date: Wed, 31 Jan 2007 11:13:07 +0200
Message-ID: <1170234787.6746.22.camel@amit-laptop>
References: <20070131075249.GA22115@srcf.ucam.org>
Reply-To: amit.kucheria@nokia.com
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: ipw2100-devel@lists.sourceforge.net, linux-pm@lists.osdl.org,
   netdev@vger.kernel.org
To: ext Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <linux-pm-bounces@lists.osdl.org>
In-Reply-To: <20070131075249.GA22115@srcf.ucam.org>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-31 at 07:52 +0000, ext Matthew Garrett wrote:
> Based on previous discussions, I've implemented a rough attempt at =

> providing some level of basic runtime power management on the ipw2100 =

> chipset. This patch does the following:
> =

> 1) On load, it initialises the hardware and then quiesces it again
> 2) On interface up, it powers the hardware back up
> 3) On interface down, it powers the hardware down and puts the chip in =

> D3
> 4) It attempts to behave correctly over suspend/resume - ie, if the =

> interface was down beforehand, it will ensure that the chip is powered =

> down

This isn't quite runtime power management in my way of thinking. I sort
of expected this to be a fundamental characteristic of well-behaved
drivers, but then I don't have too much experience with PCI on x86
platforms.

With runtime power management, I would try to put the device into low
power states when it is UP. That's what drivers on the OMAP platform
(N800, 770) do.

What is the latency in changing between different PCI power states for
peripherals?

Would it be possible e.g. to put the peripheral into a low power state
after each Tx/Rx (with reasonable hyteresis)?

<snip>

> The situation is slightly more complicated for wired interfaces. As =

> previously discussed, we potentially want three interface states (on, =

> low power, off) with the intermediate one powering down as much of the =

> hardware as possible while still implementing link detection.

And this low power state is what the HW should be in all the time,
except when it has work to do.

Regards,
Amit
