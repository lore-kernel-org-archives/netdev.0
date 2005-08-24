From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: mv643xx(2/20): use MII library for PHY management
Date: Wed, 24 Aug 2005 10:33:26 +1000
Message-ID: <1124843606.5158.124.camel@gaston>
References: <20050328233807.GA28423@xyzzy> <20050328234225.GB29098@xyzzy>
	 <430BC09A.3090401@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>, Netdev <netdev@oss.sgi.com>,
        Jeff Garzik <jgarzik@pobox.com>, Ralf Baechle <ralf@linux-mips.org>,
        Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Huth <mhuth@mvista.com>
In-Reply-To: <430BC09A.3090401@mvista.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-08-23 at 17:34 -0700, Mark Huth wrote:
> It's good to use the abstractions and common code, but in this case 
> there is a significant performance difference.  The MDIO read/write on 
> this family does a cpu spin wait for the mdio operation to complete. 
> Last time I measured this (back when fixing up a 2.4.20 implementation) 
> I got around 100 us for the mii_ioctl path, of which a good bit was in 
> the spin loop waiting for the MDIO operation to complete.  A quick look 
> seems to indicate the spin loop is still in this version of the driver.
> 
> Given that the NIC chip gives cheap access to the link status and a 
> couple of other interesting bits, the change to use the mii library has 
> a performance impact.

Is it possible to implement the mdio functions without a spin loop ?
Also, it might be a good idea to use the PHY driver model (a-la sungem)
rather than miilib...

Ben.
