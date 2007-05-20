From: Vitaly Bordug <vbordug@ru.mvista.com>
Subject: Re: STRANGE ERROR
Date: Sun, 20 May 2007 20:51:24 +0400
Message-ID: <20070520165124.GA12025@server.dev.rtsoft.ru>
References: <dcf706c60705191530x5a78f9aewbb520a97ad516f6d@mail.gmail.com> <20070519163402.b087b9d7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Sasa Ostrouska <casaxa@gmail.com>, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:56797 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1758669AbXETQv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2007 12:51:29 -0400
Content-Disposition: inline
In-Reply-To: <20070519163402.b087b9d7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 19, 2007 at 16:34 -0700, Andrew Morton wrote:
> On Sun, 20 May 2007 00:30:55 +0200 "Sasa Ostrouska" <casaxa@gmail.com> wrote:
> 
> > Hi everybody,
> > 
> > I tried today to upgrade the kernel to 2.6.21.1 and i got the same
> > error during the boot time.
> > Here is the dmesg of the 2.6.20.2, can somebody tell me what this is ?
> > 
> > ...
> >
> > Marvell 88E1101: Registered new driver
> > Fixed PHY: Registered new driver
> > driver_bound: device fixed@100:1 already bound
> 
> I don't know what caused that one.
>

this is because of issue in fixed phy driver initialisation
- have a patch but need to test it a bit more.
 
> > Device 'fixed@100:1' does not have a release() function, it is broken
> > and must be fixed.
> > BUG: at drivers/base/core.c:104 device_release()
> > 
> > Call Trace:
> >  [<ffffffff802ec380>] kobject_cleanup+0x53/0x7e
> >  [<ffffffff802ec3ab>] kobject_release+0x0/0x9
> >  [<ffffffff802ecf3f>] kref_put+0x74/0x81
> >  [<ffffffff8035493b>] fixed_mdio_register_device+0x230/0x265
> >  [<ffffffff80564d31>] fixed_init+0x1f/0x35
> >  [<ffffffff802071a4>] init+0x147/0x2fb
> >  [<ffffffff80223b6e>] schedule_tail+0x36/0x92
> >  [<ffffffff8020a678>] child_rip+0xa/0x12
> >  [<ffffffff80311714>] acpi_ds_init_one_object+0x0/0x83
> >  [<ffffffff8020705d>] init+0x0/0x2fb
> >  [<ffffffff8020a66e>] child_rip+0x0/0x12
> 
> This appears to have happened because fixed_mdio_register_device() (or
> phy_device_create) didn't suitably initialise phy_device.dev.
> 
> But I don't immediately see why this doesn't affect all phy drivers. 
> Presumably it's the fixed driver which is at fault.  Jeff, how is this
> supposed to work?
> 
the fixed phy used to have "specific" bus bound stuff 
but I've reworked this point.

