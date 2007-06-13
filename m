From: Kyuma Ohta <whatisthis@jcom.home.ne.jp>
Subject: Re: [patch 1/6] 8139too: force media setting cleanup
Date: Wed, 13 Jun 2007 21:52:56 +0900
Message-ID: <1181739176.23954.23.camel@melchior>
References: <200705232134.l4NLYcm2000578@shell0.pdx.osdl.net>
	 <46560567.5060708@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, leewkb@yahoo.com,
	netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759418AbXFMRBi@vger.kernel.org>
In-Reply-To: <46560567.5060708@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I was testing 2.6.22-rc4 from yesterday,
but communication speed  of 8139 side is very slower 
than 2.6.21.* (less than 10kbytes/sec at  
100MBPS,FULL-DUPLEX).
I was not test from 2.6.22-rc ,yesterday I started to test 2.6.22-rc.

So, I *must* set HALF-DUPLEX to 8139 side below:
ethtool -s ethx speed 100 duplex half autoneg on 
*x is number of 8139 assigned from udev.

So,Pls.apply this patch to upstream,and I test this too.

Best Regards,
Ohta.

Appendix information:
archtecture: x86_64
Main Board : Gigabyte GA-M69P-M3 (rev.1.0?)
MPU: Athlon 64x2 4600+ (Not overclocked)
Chipset : nVidia nForce430+GForce 6150 Complex chip
Memory : PC-5300 2GB (w/shared graphix memory)
Ether: nForce430 (within complex chip,using forcedeth)
             Realtec 8139C (+?) (on PCI Slot,using 8139too)
OS: Debian GNU/Linux "sid" (after "etch",using glibc2.5).

On 2007-05-24 (Thu) 17:36 -0400 , Jeff Garzik Wrote:
> akpm@linux-foundation.org wrote:
> > From: Bernard Lee <leewkb@yahoo.com>
> > 
> > Setting bit 4 & 5 alone in 8139too module media option does not really
> > force 100Mbps full-duplex mode.  When media option bit 0-3 is cleared,
> > 8139too module does not force media setting.  Therefore, bit 0-3 requires
> > to be set for bit 4 & 5 to take effect.  The hidden bit 0-3 setting is not
> > stated in module description.
> > 
> > It can be fixed by changing rtl8139_private structure default_port bitfield
> > from 4-bit to 6-bit.
> > 
> > Besides, module media bit 9 is a duplicate of bit 4 (full-duplex).  It is
> > suggested that bit 9 is freed.  A remark is added to module description
> > that bit 0 can be used to force setting.  It helps to clarify 10Mbps
> > half-duplex mode.
> > 
> > Signed-off-by: Bernard Lee <leewkb@yahoo.com>
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  drivers/net/8139too.c |    8 ++++----
> >  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> (re-replying, just to refresh everybody on the status)
> 
> The status of this patch is HOLD, and has been for months.
> 
> AFAICS this is a behavior change that differs from other Becker-derived 
> drivers.  I would suggest looking at other drivers.
> 
> Furthermore, people should be using ethtool to set media.  Rather than 
> changing the behavior of this module parameter to be non-standard, I 
> feel it is better to (a) leave it as is or (b) remove it completely.
> 
> 	Jeff
