From: David Fries <david@fries.net>
Subject: Re: [2.6 patch] eepro100 resume patch
Date: Sat, 14 Jul 2007 08:44:55 -0500
Message-ID: <20070714134454.GA1781@spacedout.fries.net>
References: <20070714000151.GA31482@spacedout.fries.net> <46984CF0.8080700@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761473AbXGNNpZ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46984CF0.8080700@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2007 at 09:11:28PM -0700, Kok, Auke wrote:
> [adding netdev]
> 
> David Fries wrote:
> >When I did a software suspend to disk then resumed the Intel network
> >card using eepro100 driver would be unable to transmit packets.  I
> >tracked this down and found a register write after the print message
> >"DP83840 specific setup" which wasn't being executed when the system
> >was restored.  This fix moves that write and another write which
> >forces the link speed and duplex.
> >
> >After doing this work and preparing the patch I checked out the
> >mailing list only to find a patch that removes the eepro100.  I then
> >updated Kconfig, though I wonder why it didn't have a similar message
> >in it long time ago.
> >
> >I too had tried the e100 driver some time ago and it didn't work,
> 
> That argument is pretty useless right now. Please *test* e100 and *report 
> issues*. I recently did some very intensive suspend/resume testing (and 
> fixes) on e100 and I have yet to hear of any problems with it since... that 
> was 2.6.18 or so even.
> 
> >eepro100 did and I've been using it so long that I've almost forgotten
> >about that.  I just gave the e100 driver a try and I've been running
> >for about an hour now without any problems and it does resume after a
> >suspend to disk operation.
> 
> I don't think I need to NAK this. I doubt that Jeff Garzik will apply this 
> in the first place. eepro100 is on it's way out, so let's focus on what 
> matters.
> 
> Auke

Sorry for not making the point of my e-mail clear.

It would be a good idea when a driver is being obsoleted to flag that
in the Kconfig and give alternatives when they exist.  It will
increase the chance that people will pick the supported driver.

My other point was that e100 didn't use to work with my hardware, I
now have about 12 hours of using the e100 driver without any issues
that I've seen.  Consider that a success report.
0000:00:08.0 Ethernet controller: Intel Corporation 82557/8/9 [Ethernet Pro 100] (rev 01)

Signed-off-by: David Fries <David@Fries.net>

Index: drivers/net/Kconfig
===================================================================
RCS file: 
/home/david/kernel/k/spacedout/patches/linux/drivers/net/Attic/Kconfig,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 Kconfig
--- drivers/net/Kconfig	13 Jul 2007 23:16:36 -0000	1.1.2.1
+++ drivers/net/Kconfig	13 Jul 2007 23:31:29 -0000
@@ -1467,6 +1467,11 @@
 	depends on NET_PCI && PCI
 	select MII
 	help
+	  ** Warning ** eepro100 (this driver) has been requested to be
+	  removed from the kernel source tree.  Please use e100 and report
+	  any bugs as that is the driver that will be supported going
+	  forward.
+
 	  If you have an Intel EtherExpress PRO/100 PCI network (Ethernet)
 	  card, say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.

-- 
David Fries <david@fries.net>
http://fries.net/~david/ (PGP encryption key available)
