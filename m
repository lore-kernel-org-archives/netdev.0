From: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 18:24:48 +0200
Message-ID: <1208276688.20681.71.camel@FWR-FLAB>
References: <20080414213238.GB28833@kroah.com>
	 <200804151525.57340.oliver@neukum.org> <1208268742.20681.29.camel@FWR-FLAB>
	 <200804151614.47977.oliver@neukum.org> <1208271789.20681.45.camel@FWR-FLAB>
	 <20080415153408.GB7996@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080415153408.GB7996-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Tue, 2008-04-15 at 08:34 -0700, Greg KH wrote:
> On Tue, Apr 15, 2008 at 05:03:09PM +0200, Filip Aben wrote:
> > 
> > On Tue, 2008-04-15 at 16:14 +0200, Oliver Neukum wrote:
> > > Am Dienstag, 15. April 2008 16:12:22 schrieb Filip Aben:
> > > > 
> > > > On Tue, 2008-04-15 at 15:25 +0200, Oliver Neukum wrote:
> > > > > Am Montag, 14. April 2008 23:32:39 schrieb Greg KH:
> > > > > > Hi all,
> > > > > > 
> > > > > > Here's a patch that I have cleaned up for context only from Option that
> > > > > > is a USB serial / network device all in one.
> > > > > > 
> > > > > > I'd like to see this go into 2.6.26, so any review comments by anyone
> > > > > > who wishes to review any portion of this would be greatly apprecited.
> > > > > 
> > > > > The driver implements an ioctl to disable autosuspend. This seems
> > > > > unnecessary to me, as you can do that via sysfs, too. Is this included
> > > > > to work around permission problems? Can somebody explain?
> > > > > 
> > > > > 	Regards
> > > > > 		Oliver
> > > > 
> > > > This is added to support card firmware upgraders who will need to
> > > > disable suspend, even on (embedded) systems that don't have sysfs
> > > > mounted.
> > > 
> > > How do they enable autosuspend without sysfs?
> > 
> > Good point. No idea. I suppose it's easier to rely on something that
> > will always work, rather then making assumptions about suspend based on
> > whether sysfs is mounted or not.
> 
> Like I always like to point out, my _phone_ has sysfs mounted, I really
> doubt any 2.6 embedded system would not have it mounted these days, it
> is very useful for things like this.
> 
> So I'll go delete that "special" ioctl, that's not a good thing to do,
> use the common interfaces that all USB devices rely on instead, don't do
> something different for just one type of USB device.

Fair enough.

> 
> I'm also a bit concerned about the special "set radio" ioctl as well.
> Filip, what uses that ioctl?  If it's really necessary, can't a sysfs
> file do the same thing?

Currently I don't think anybody uses it for Linux. I added it because
our non-Linux drivers had this functionality. It's used for example by
our connection managers/tools to disable the RF-part when the laptop
goes to sleep ( but keeps the USB bus powered&suspended ). This is a
requirement for quite some operators.
But yes, I suppose the same could be done through sysfs.

Regards,

Filip-
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
