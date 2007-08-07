From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 7 Aug 2007 09:26:35 +0200
Message-ID: <20070807072635.GA2120@ff.dom.local>
References: <JMDDIG$C8916D611655799A77AD19198F8EDA75@xandmail.com> <46B79047.4060402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean-Baptiste Vignaud <vignaud@xandmail.fr>, mingo <mingo@elte.hu>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	tglx <tglx@linutronix.de>,
	torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:55539 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754929AbXHGH0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 03:26:06 -0400
Content-Disposition: inline
In-Reply-To: <46B79047.4060402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 06, 2007 at 05:19:03PM -0400, Chuck Ebbert wrote:
> On 08/06/2007 04:42 PM, Jean-Baptiste Vignaud wrote:
> > Mmm, bad news, after 4 hours of intensive network stressing, one of the 2 3com card failed with the latest fedora kernel.
> > 
> > Aug  6 22:31:09 loki kernel: NETDEV WATCHDOG: eth2: transmit timed out
> > Aug  6 22:31:09 loki kernel: eth2: transmit timed out, tx_status 00 status e601.
> > Aug  6 22:31:09 loki kernel:   diagnostics: net 0ccc media 8880 dma 0000003a fifo 8000
> > Aug  6 22:31:09 loki kernel: eth2: Interrupt posted but not delivered -- IRQ blocked by another device?
> > Aug  6 22:31:09 loki kernel:   Flags; bus-master 1, dirty 26085000(8) current 26085000(8)
> > Aug  6 22:31:09 loki kernel:   Transmit list 00000000 vs. ffff81007c807700.
> > 
> > Stressing eth2 by copying large files on a samba on share and eth0 by downloading big files on the internet.
> 
> So even the full revert doesn't fix the 3Com driver, it just makes it less
> likely to do that.
> 
> The other patch probably won't be any better -- I'd guess there's some
> kind of IRQ handling bug in that driver.
> 

I don't know how fast are these 3com chips regarding these 8390
described by Alan, and how are irqs shared on Jean-Baptiste's box,
but I'm surprised they could have worked sharing interrupts and
without such time outs before this change in 2.6.21. It seems some
of those older chips, because of slowness, could have transmit
problems even without irq sharing. So, IMHO, if possible, there
should be never irq sharing enabled between two (or more) drivers
using both disable_irq.

These time out problems were reported long time ago, but I think
it would be nice if this thread could at least remove these new
problems reported only after 2.6.21, which it seems is possible
now, after Marcin's diagnose: by reverting the whole 2.6.21 patch
or by this current temporary patch in 2.6.23-rc2's resend.c.
It would be nice if you could try this patch too.

BTW: Jean-Babtiste, could you send or point to you current configs?
I mean at least proc/interrupts, but with dmesg and .config it would
be even better. (I assume this last report was about the revert patch
mentioned by Chuck, not the one below your message?)

Regards,
Jarek P.
