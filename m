From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: What is in bcm43xx-wireless-dev.git?
Date: Sun, 14 Jan 2007 11:15:43 +0100
Message-ID: <200701141115.43799.mb@bu3sch.de>
References: <20070113024543.aj2n40s4k0g0cgws@webmail.spamcop.net>
	<200701132051.52559.mb@bu3sch.de>
	<20070113211030.11zo8cokcsoskccg@webmail.spamcop.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
In-Reply-To: <20070113211030.11zo8cokcsoskccg-2RFepEojUI3Rd1RZctBqVdHuzzzSOjJt@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 14 January 2007 03:10, Pavel Roskin wrote:
> Quoting Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>:
> 
> > > I haven't looked at the code yet, but I tried to locate the bad commit.  I
> > tried
> > > commit a13f85d8a8eb40dfd157ab78c2fb91b5765b7b9d, which is your last merge,
> > just
> > > before the SSB changes.
> >
> > Yeah, sure. I know that this is the commit which introduced this.
> 
> Basically, you set up DMA on the PCI device, but use it on the SSB device.
> That's inconsistent.  dma_alloc_coherent() is very picky on x86_64 and crashes
> if dev->dma_mask is NULL, which was the case for the SSB device.
> 
> Looking at the patch, it's clear that the SSB device is used instead of the PCI
> device in some places.  I restored the old logic.  If you meant to switch to
> SSB devices, then please remove the last PCI references from that file.

Already done. Please pull my tree and check if it still crashes.

> The patch is attached.  It fixes the crash.  I didn't check that it's complete.
> I really don't like the long chain of dereferences, and I hope you'll come up
> with something better.

No. I don't think we have shorter chains in other subsystems like PCI. They
are just hidden.

We could probably get rid of one level in the DMA code, by embedding the DMA
structs into the device struct. But I think there are more important things
to do at the moment.

> I still cannot associate.  The kernel log is attached.  Notice massive assertion
> failures.
> 
> > Note that LO calibration is horribly broken in my tree.
> 
> I guess that's what the assertion failures are about.

You're right.

> > So you have a very weak signal, if any. My 4318 has no signal, for example.
> > So basically don't expect to be able to transmit any data.
> > This includes association.
> 
> Actually, I could scan, and I got 7 access points around.  Only one is in my
> apartment.

RX sensitivity is not quite as bad.

> > But I think you should be able to assoc with a plain linville tree.
> 
> Nope.  Although I got DadWifi to work, and this message will we sent over it.
> So it's not like I'm missing something essential about d80211 stack.

Well, I don't really know what to do all about this.
It's strange. I have people reporting that exactly the same cards work
and people reporting that exactly the same cards don't work over and
over again.
So, well. What to do? :)

-- 
Greetings Michael.
