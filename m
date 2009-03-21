From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [Bugme-new] [Bug 12876] New: irq 18: nobody cared after down-ing
 an e1000 interface
Date: Fri, 20 Mar 2009 22:05:30 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.1.10.0903202201170.5168@jbrandeb-MOBL1.amr.corp.intel.com>
References: <bug-12876-10286@http.bugzilla.kernel.org/> <20090315143058.726ad8e9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"lkundrak@v3.sk" <lkundrak@v3.sk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21458 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbZCUFFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:05:34 -0400
In-Reply-To: <20090315143058.726ad8e9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Mar 2009, Andrew Morton wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=12876
> > I get the following OOPS when I down the e1000 network interface:
> > 
> > irq 18: nobody cared (try booting with the "irqpoll" option)
> > Pid: 9014, comm: udevd Tainted: G        W  2.6.29-0.237.rc7.git4.fc11.i586 #1
> > Call Trace:
> >  [<c0471f2b>] __report_bad_irq+0x33/0x74
> >  [<c047205e>] note_interrupt+0xf2/0x150
> >  [<c04711e0>] ? handle_IRQ_event+0x4f/0x58
> >  [<c04725e8>] handle_fasteoi_irq+0x94/0xb7
> >  [<c0472554>] ? handle_fasteoi_irq+0x0/0xb7
> >  <IRQ>  [<c04045ac>] ? common_interrupt+0x2c/0x40
> > handlers:
> > [<c05f3cb6>] (ata_sff_interrupt+0x0/0xb1)
> > [<c06079ec>] (usb_hcd_irq+0x0/0xa3)
> > Disabling IRQ #18
> > 
> > As you can see, the IRQ 18 is shared with ata_sff and usb_hcd.
> > 
> > I've tried to comment out e1000_free_irq() call from e1000_close() and added a
> > printk() to e1000_intr(). After that, the problem didn't occur, but I've not
> > seen the output of the printk in e1000_intr() (It was visible while the
> > interface was up), as if it weren't called. Seems like the way shared
> > interrupts work is beyond my understanding.

Please try the patch attached to the bug, Alan Cox pointed out that it was 
likely the driver was racy during close and was re-enabling interrupts.

I spotted two possible areas where this was possible and put in checks for 
__E1000_DOWN before re-enabling ints in those spots.

I'm offline for a week and I'll reconnect and check back when I return.
