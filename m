From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [updated] PHY fixed driver: rework release path and
 update phy_id notation
Date: Fri, 20 Jul 2007 00:57:02 -0700
Message-ID: <20070720005702.b2b644e7.akpm@linux-foundation.org>
References: <20070718233804.24451.22543.stgit@localhost.localdomain>
	<20070719232337.184942e0.akpm@linux-foundation.org>
	<20070720115039.05f50f0f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57699 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757313AbXGTH5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 03:57:19 -0400
In-Reply-To: <20070720115039.05f50f0f@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Jul 2007 11:50:39 +0400 Vitaly Bordug <vitb@kernel.crashing.org> wrote:

> On Thu, 19 Jul 2007 23:23:37 -0700
> Andrew Morton wrote:
> 
> > On Thu, 19 Jul 2007 03:38:04 +0400 Vitaly Bordug
> > <vitb@kernel.crashing.org> wrote:
> > 
> > > 
> > > device_bind_driver() error code returning has been fixed.  
> > > release() function has been written, so that to free resources 
> > > in correct way; the release path is now clean. 
> > >  
> > > Before the rework, it used to cause 
> > >  Device 'fixed@100:1' does not have a release() function, it is
> > > broken and must be fixed. 
> > >  BUG: at drivers/base/core.c:104 device_release() 
> > >   
> > >  Call Trace:   
> > >   [<ffffffff802ec380>] kobject_cleanup+0x53/0x7e 
> > >   [<ffffffff802ec3ab>] kobject_release+0x0/0x9 
> > >   [<ffffffff802ecf3f>] kref_put+0x74/0x81 
> > >   [<ffffffff8035493b>] fixed_mdio_register_device+0x230/0x265 
> > >   [<ffffffff80564d31>] fixed_init+0x1f/0x35 
> > >   [<ffffffff802071a4>] init+0x147/0x2fb 
> > >   [<ffffffff80223b6e>] schedule_tail+0x36/0x92 
> > >   [<ffffffff8020a678>] child_rip+0xa/0x12 
> > >   [<ffffffff80311714>] acpi_ds_init_one_object+0x0/0x83 
> > >   [<ffffffff8020705d>] init+0x0/0x2fb 
> > >   [<ffffffff8020a66e>] child_rip+0x0/0x12   
> > >  
> > >  
> > > Also changed the notation of the fixed phy definition on 
> > > mdio bus to the form of <speed>+<duplex> to make it able to be used
> > > by gianfar and ucc_geth that define phy_id strictly as "%d:%d" and
> > > cleaned up the whitespace issues.
> > >  
> > 
> > Confused.  Does the above refer to the difference between this patch
> > and the previous version, or does it just describe this patch?
> > Hopefully the latter, because the former isn't interesting, long-term.
> > 
> Latter. IOW, that does mean, that mdio bus registered by this driver, now uses
> same naming conventioun that other PHYLIB things use. Hereby it will make it able to be used in 
> NIC drivers other than fs_enet (and gianfar and ucc_geth are now points of interest).
> 
> > If is _is_ a full standalone description of this patch then it's a
> > bit hard to follow ;)
> > 
> Hmm -so what are my options - change the description and resubmit?

umm, I guess it's OK as-is.  But it wasn't clear to me which sort of
changelog it was.


> > > +config FIXED_MII_1000_FDX
> > > +	bool "Emulation for 1000M Fdx fixed PHY behavior"
> > > +	depends on FIXED_PHY
> > > +
> > > +config FIXED_MII_AMNT
> > > +        int "Number of emulated PHYs to allocate "
> > > +        depends on FIXED_PHY
> > > +        default "1"
> > > +        ---help---
> > > +        Sometimes it is required to have several independent
> > > emulated
> > > +        PHYs on the bus (in case of multi-eth but phy-less HW for
> > > instance).
> > > +        This control will have specified number allocated for each
> > > fixed
> > > +        PHY type enabled.
> > 
> > Shouldn't these be runtime options (ie: module parameters)?
> > 
> I thought about it but this thing is more like the one that will never tend/required to change while\
> configured.. Will add if you see it appropriate though.

99% of users don't compile their own kernels: their vendor will have to
make this decision for them, and it sounds like any decision which they
make will be wrong for some of their users?

