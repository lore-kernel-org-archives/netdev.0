From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2011-11-22
Date: Tue, 22 Nov 2011 16:26:03 -0500
Message-ID: <20111122212603.GF8452@tuxdriver.com>
References: <20111122.151429.253381379981773726.davem@davemloft.net>
 <20111122205655.GE8452@tuxdriver.com>
 <20111122.160511.2302883259439708995.davem@davemloft.net>
 <20111122.161322.454163033398038634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111122.161322.454163033398038634.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2011 at 04:13:22PM -0500, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 22 Nov 2011 16:05:11 -0500 (EST)
> 
> > From: "John W. Linville" <linville@tuxdriver.com>
> > Date: Tue, 22 Nov 2011 15:56:55 -0500
> > 
> >> On Tue, Nov 22, 2011 at 03:14:29PM -0500, David Miller wrote:
> >>> From: "John W. Linville" <linville@tuxdriver.com>
> >>> Date: Tue, 22 Nov 2011 14:35:05 -0500
> >>> 
> >>> > Here is the latest batch of fixes intended for 3.2.  This includes a
> >>> > correction for a user-visible error in mac80211's debugfs info, a fix
> >>> > for a potential memory corrupter in prism54, an endian fix for rt2x00,
> >>> > an endian fix for mac80211, a fix for a NULL derefernce in cfg80211, a
> >>> > locking fix and a deadlock fix for p54spi, and a pair of rt2x00 fixes
> >>> > for handling some spurious interrupts that hardware can generate.
> >>> > 
> >>> > Please let me know if there are problems!
> >>> 
> >>> The rt2800pci change doesn't look correct.
> >>> 
> >>> If the IRQ line is shared with another device, this change will make it
> >>> never see interrupts.  Once you say "IRQ_HANDLED" the IRQ dispatch
> >>> stops processing the interrupt handler list.
> >> 
> >> I thought this at first as well.  But looking at the code in
> >> kernel/irq/handle.c doesn't support that conclusion.  In fact, every
> >> handler gets invoked no matter what they all return.  All of the irq
> >> handler return values are ORed together and passed to note_interrupt.
> >> Only if every irq handler returns IRQ_NONE does the code in
> >> kernel/irq/spurious.c start getting involved.
> >> 
> >> Anyway, this seems to be safe even for shared interrupts.  That said,
> >> this is a bit ugly.  But it makes a serious difference in performance
> >> for those afflicted with this issue.
> > 
> > It just means that we won't notice spurious interrupts if the device
> > sharing the line with rt2800pci generates one.
> > 
> > This change is wrong.
> 
> BTW, look at it this way, if what you say is true John then what's the point
> in returning any specific value at all?
> 
> Everyone can just return IRQ_HANDLED and everything would just work.
> 
> But you know that's not the case, and that it's important that this value
> is returned accurately.

Alright, that a good point.  I'll drop those two patches.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
