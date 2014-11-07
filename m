From: Riku Voipio <riku.voipio-X3B1VOXEql0@public.gmane.org>
Subject: Re: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net
 onarndale platform
Date: Fri, 7 Nov 2014 10:44:49 +0200
Message-ID: <20141107084449.GA11078@afflict.kos.to>
References: <20141104200914.GN23178@opensource.wolfsonmicro.com>
 <C89EFD3CD56F64468D3D206D683A8D22039FFC5F@ldam-msx2.fugro-nl.local>
 <20141105150258.GR23178@opensource.wolfsonmicro.com>
 <20141106090651.GA19109@afflict.kos.to>
 <20141106100104.GS23178@opensource.wolfsonmicro.com>
 <20141106120416.GA20162@afflict.kos.to>
 <C89EFD3CD56F64468D3D206D683A8D22039FFE16@ldam-msx2.fugro-nl.local>
 <20141106124653.GV23178@opensource.wolfsonmicro.com>
 <C89EFD3CD56F64468D3D206D683A8D22039FFE39@ldam-msx2.fugro-nl.local>
 <20141106140940.GW23178@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Stam, Michel [FINT]" <M.Stam-76PGuD9xVjg@public.gmane.org>, freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Charles Keepax <ckeepax-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141106140940.GW23178-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 06, 2014 at 02:09:40PM +0000, Charles Keepax wrote:
> On Thu, Nov 06, 2014 at 03:01:56PM +0100, Stam, Michel [FINT] wrote:
> > Hello Charles and Riku,
> > 
> > I've quickly tested this on a 3.10 kernel i had around;
> > I enabled CONFIG_PM, CONFIG_PM_RUNTIME, CONFIG_PM_AUTOSLEEP,
> > CONFIG_SUSPEND, CONFIG_SUSPEND_FREEZER, CONFIG_FREEZER in the kernel (by
> > default they are disabled for our setup, I enabled anything regarded to
> > runtime powermanagement to be sure I would trigger suspend/resume).
> > 
> > Then:
> > cd /sys/bus/usb/devices/1-2/power
> > echo auto > control
> > echo 1 > autosuspend
> > echo 0 > autosuspend_delay_ms
> > echo enabled > wakeup
> > 
> > # make sure there's no processes routing traffic over the eth1 interface
> > 
> > ifconfig eth1 down
> > sleep 4 # sleep some arbitrary long time
> > ifconfig eth1 up
> > 
> > check dmesg; it will reset back to 100 Mbps/full duplex.
> > 
> > This confirms that the suspend / resume does not work well. So long as
> > the suspend is not triggered, it does seem to work, though. I cannot say
> > whether the original issue that triggered this is still around; the ASIX
> > chip setup we use is soldered to the PCB and hooked up to a fixed device
> > on-board. 
> > I also tried to ping the device on the other side of the ASIX chip after
> > the suspend/resume cycle, I could not ping it. I cannot conclusively say
> > that this is due to the ASIX driver, as the device on the other side
> > does not like switching PHY speeds (it may go into a non-responsive
> > state). It is for this reason that we run it at half duplex/ 10Mbps at
> > all times.
> > 
> > As said; we are not using this kind of power management, so it does not
> > raise any issues for us. I am merely pointing out that this may need
> > work (in the future?).
 
> Cool thanks for checking this I will make a note in the commit
> message that suspend/resume might need some more work.

Thanks for digging through,

Make sure the commit message is clear that your patch is a regression
fix - following just this thread it might be a bit unclear.

Riku

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
