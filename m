From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: fec: fix regression on i.MX28 introduced by
	rx_copybreak support
Date: Wed, 8 Oct 2014 10:12:48 +0100
Message-ID: <20141008091248.GE5182@n2100.arm.linux.org.uk>
References: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de> <54340FA4.509@cogentembedded.com> <063D6719AE5E284EB5DD2968C1650D6D174C6C14@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>,
	Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C6C14@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 08, 2014 at 08:54:58AM +0000, David Laight wrote:
> Hmmm... in that case you may not want the compiler to convert the bit value
> to a 'bool' at all.
> 
> Passing 'id_entry->driver_data' through (that doesn't look like a field name for
> 'quirk flags) would generate better code.
> 
> Even better would be to reference the flag directly from 'ndev'.
> A pointer indirection for the test if probably faster then passing
> another argument.

A far better idea would be to copy the quirks into the fec_net_private
structure, storing them as a 'unsigned int' value, and test them from
there.  This is /much/ more efficient than jumping through the hoops to
retrieve id_entry, and then testing the 64-bit driver_data value.

I've had such a patch since about the beginning of the year (and patches
which add stuff like byte queue limits, which are really needed now that
we have a /huge/ transmit ring), but I can't keep up with rebasing the
patch set, and properly tested and performance impacts evaluated due to
the rate of FEC changes.  I never finished rebasing the set after Andy's
TSO work...

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
