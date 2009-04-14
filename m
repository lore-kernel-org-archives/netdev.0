From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH] tg3: fix big endian MAC address collection failure
Date: Tue, 14 Apr 2009 03:51:25 +0000
Message-ID: <1239681085.3278.122.camel@mulgrave.int.hansenpartnership.com>
References: <1239636594.3278.31.camel@mulgrave.int.hansenpartnership.com>
	 <20090413.143211.214694858.davem@davemloft.net>
	 <1239658951.3278.104.camel@mulgrave.int.hansenpartnership.com>
	 <1239661059.9237.4.camel@HP1>
	 <1239661934.3278.113.camel@mulgrave.int.hansenpartnership.com>
	 <20090414012548.GB11615@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20090414012548.GB11615@xw6200.broadcom.net>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-04-13 at 18:25 -0700, Matt Carlson wrote:
> On Mon, Apr 13, 2009 at 03:32:14PM -0700, James Bottomley wrote:
> > On Mon, 2009-04-13 at 15:17 -0700, Michael Chan wrote:
> > > On Mon, 2009-04-13 at 14:42 -0700, James Bottomley wrote:
> > > 
> > > > ---
> > > > On Mon, 2009-04-13 at 11:37 -0700, Matt Carlson wrote:
> > > > > But that is exactly what the code is doing.  tg3_nvram_read_be32() will
> > > > > return the data in bytestream format.  A memcpy() should be all that is
> > > > > needed to transport the data to a different memory location.
> > > > 
> > > > But not the one you've done.  cpu_to_be32 is a nop pass through on our
> > > > architecture, so tg3_nvram_read_be32 is equivalent to tg3_nvram_read on
> > > > our architecture (i.e. identical to the code that was doing the read in
> > > > 2.6.29).  However, the memcpy is the wrong way around for us.  If you
> > > > look at an example, the original code said
> > > 
> > > The old tg3_nvram_read() had a swab32() after the readl().  The new
> > > tg3_nvram_read() no longer has the swab32().  There were too many layers
> > > of swapping in the old code and that's why Matt wanted to clean it up.
> > > 
> > > James, can do dump out the nvram content on the parisc?
> > > 
> > > ethtool -e eth0 length 0x90
> > > 
> > > Thanks.
> > 
> > Sure, ion's is
> > 
> > ion:~# ethtool -e eth0 length 0x90
> > Address         Data
> > ----------      ----
> > 0x00000000      0xaa
> > 0x00000001      0x55
> > 0x00000002      0x99
> > 0x00000003      0x66
> 
> Michael noticed that your NVRAM signature is byteswapped in NVRAM. (!)
> That also explains why the driver is trying to obtain the MAC address
> through NVRAM, rather than getting it from shared memory.  The device's
> bootcode is not working correctly.

Um, well, this is a parisc:  the device's boot code won't be working at
all (parisc doesn't have open firmware boot).  The values might be laid
down by the platform IODC, but usually for add in cards, they're the
default initialise values the card comes up with.

James


