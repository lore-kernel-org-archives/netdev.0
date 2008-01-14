From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9721] New: wake on lan fails with sky2 module
Date: Mon, 14 Jan 2008 12:50:47 -0800
Message-ID: <20080114125047.2c161b18.akpm@linux-foundation.org>
References: <bug-9721-10286@http.bugzilla.kernel.org/>
	<200801112216.08992.rjw@sisk.pl>
	<4787EB69.9060900@yahoo.de>
	<200801120010.22440.rjw@sisk.pl>
	<478A1083.5060406@yahoo.de>
	<478A2976.9000204@yahoo.de>
	<20080113112712.e93f07a4.akpm@linux-foundation.org>
	<20080114083926.03232343@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: supersud501@yahoo.de, rjw@sisk.pl, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52891 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750818AbYANUvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 15:51:08 -0500
In-Reply-To: <20080114083926.03232343@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jan 2008 08:39:26 -0800
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> > diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> > index c27c7d6..4f41a94 100644
> > --- a/drivers/net/sky2.c
> > +++ b/drivers/net/sky2.c
> > @@ -2791,6 +2791,9 @@ static void sky2_reset(struct sky2_hw *hw)
> >  	sky2_write8(hw, B0_CTST, CS_RST_SET);
> >  	sky2_write8(hw, B0_CTST, CS_RST_CLR);
> >  
> > +	/* allow writes to PCI config */
> > +	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
> > +
> >  	/* clear PCI errors, if any */
> >  	pci_read_config_word(pdev, PCI_STATUS, &status);
> >  	status |= PCI_STATUS_ERROR_BITS;
> > 
> > fixes this regression?
> > 
> > If so, we should revert that change.
> > 
> > > but i noticed another "bug" on 2.6.24-rc7-git with sky2: dmesg shows a 
> > > lot of lines every 5 seconds:
> > > 
> > > [...]
> > > [  357.400462] sky2 0000:02:00.0: error interrupt status=0xc0000000
> > > [  362.442039] printk: 41 messages suppressed.
> > > [  362.442043] sky2 0000:02:00.0: error interrupt status=0x80000000
> > > [  367.439151] printk: 18 messages suppressed.
> > > [  367.439156] sky2 0000:02:00.0: error interrupt status=0x80000000
> > > [  372.436267] printk: 30 messages suppressed.
> > > [  372.436271] sky2 0000:02:00.0: error interrupt status=0x80000000
> > > [  377.350236] printk: 19 messages suppressed.
> > > [...]
> > > 
> > > since i do not notice any errors (yet) i'll wait till next rc, maybe it 
> > > will be gone then...
> > 
> > That's not good.  is this new behaviour?
> > 
> 
> No, reverting that change will break other systems (including mine).

Reverting which change?  ac93a3946b676025fa55356180e8321639744b31?

Linus has very clearly stated on multiple occasions that patches which
fix machine A and break machine B will be reverted.  For good reasons.
I don't have a copy of those reasons handy, but it should be a well-known
thing.

If you're really interested we can cc him for a reminder, but the effects
of that upon ac93a3946b676025fa55356180e8321639744b31 might be quick.  And
terminal.
