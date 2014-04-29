From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH net-next 5/7] net:fec: add support for dumping transmit
	ring on timeout
Date: Tue, 29 Apr 2014 15:38:28 +0100
Message-ID: <20140429143828.GB26756@n2100.arm.linux.org.uk>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com> <1398773350-7293-5-git-send-email-Frank.Li@freescale.com> <063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com> <CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com> <CAHrpEqRZ1oyd6bXXqxznfw+1qwo5LVBW10mcrzLbbCHYowPetA@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F70156E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Frank Li' <lznuaa@gmail.com>, Frank Li <Frank.Li@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:57491 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933392AbaD2Oj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 10:39:28 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F70156E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 02:23:09PM +0000, David Laight wrote:
> From: Frank Li [mailto:lznuaa@gmail.com]
> > On Tue, Apr 29, 2014 at 9:01 AM, David Laight <David.Laight@aculab.com> wrote:
> > > From: Frank ...
> > >> > You probably want the read and write indexes as well.
> > >>
> > >>                      bdp == fep->cur_tx ? 'S' : ' ',
> > >>                      bdp == fep->dirty_tx ? 'H' : ' ',
> > >>
> > >> Above code already print read and write index. 'S', 'H'
> > >
> > > Gah I must be asleep!
> > > Something made be think that was to do with the ring ownership bit!
> > 
> > I think it is same thing. If I am wrong, please tell me difference.
> 
> The ownership bit in the ring flags - that the hardware uses.
> Which are printed in the next field.
> 
> I'm guessing that the reason the tx ring is 'interesting' is that there
> have been bugs where the driver and hardware disagree about which entry
> each should process next.
> Otherwise the full tx ring is likely to be very very boring.

There have been several bugs.

One is where the ring is completely owned by software (because all the
entries have been transmitted) but the driver is buggy and hasn't reaped
the ring at all, leading to a tx timeout.

The second one is where the ring appears to be completely full, because
the hardware hasn't been transmitting for various reasons (eg, there are
bugs in the way the transmitter is started.)

The third one is where the transmitter skips a ring entry on earlier iMX
hardware.

However, those are specific bugs.  The point of dumping the whole ring is
to allow bugs to be diagnosed, because we can then see the state of the
ring, and start looking for likely causes of the symptoms that are visible.
With the driver as it currently is, the only thing we know is "oops, the
transmit seemed to stop for some reason" and we hope that resetting the
device gets it going again - after many seconds of it being non-responsive.

This is how I've sorted out many issues with this driver.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
