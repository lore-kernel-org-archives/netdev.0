From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [RFT] e100 driver on ARM
Date: Tue, 17 Apr 2007 13:35:07 -0400
Message-ID: <20070417173507.GB5575@csclub.uwaterloo.ca>
References: <44FC0261.6010807@garzik.org> <20060904123123.GB1285@xi.wantstofly.org> <460AF480.7050609@intel.com> <460B4BF2.1070803@roinet.com> <20070329141041.GA3510@csclub.uwaterloo.ca> <46239138.4040408@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jeff Garzik <jeff@garzik.org>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: David Acker <dacker@roinet.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161216AbXDQRfK@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46239138.4040408@roinet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 16, 2007 at 11:07:36AM -0400, David Acker wrote:
> Lennart Sorensen wrote:
> >Which PCI host controller are you using with the PXA255?  We tried using
> >a PXA255 based system with a PCI controller a couple of years ago and
> >have to change to a different cpu in the end due to the PCI controller
> >simply not being valid PCI.  The PXA255 wasn't designed for PCI, and I
> >get the impression that non of the PCI companion chips for it do a good
> >enough job to actually add it correctly.
> >
> 
> Sorry for the delay in responding...my wife and I just had twins!
> 
> We are using the IT8152G RISC-to-PCI companion chip.

Well the IT8152G+PXA255 combination used on the SBC we tried a couple of
years ago did not work.  The PCI bus had errors and the SBC maker gave
up trying to fix it.  We switched to a Geode SC1200 based board instead
which works fine PCI wise.

My suspicision (although it is only that) is that the PXA255 trying to
access memory may cause interruptions in PCI bus master transfers, which
is of course not permitted by the PCI spec (at least the way I read it).
We tried it with RTL8139, AMD 972 (both ethernet) as well as a number of
T1/E1 and DDS wan cards from sangoma.  The wan cards had the most issues
with it (they drivers and hardware would get out of sync due to PCI bus
problems), while the ethernet just had occational packet corruption.  I
will certainly never consider using a PXA + ITE pci controller
combination ever again.  Too bad since the performance of the PXA is
amazing.  The PXA chips are not designed to speak to PCI, and the ITE
companion chip doesn't quite do the job of pretending it was.  I would
expect problems if you do pci bus master transfers and/or any kind of
PCI bus traffic load.

--
Len Sorensen
