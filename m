From: Andrew de Quincey <adq@lidskialf.net>
Subject: Re: wol support in forcedeth v25
Date: Tue, 20 Apr 2004 12:36:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404201236.41188.adq@lidskialf.net>
References: <Pine.GHP.4.44.0404201259390.24990-100000@elektron.its.tudelft.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: a.verweij@student.tudelft.nl
In-Reply-To: <Pine.GHP.4.44.0404201259390.24990-100000@elektron.its.tudelft.nl>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 20 April 2004 12:13, Arjen Verweij wrote:

I found how I could get it going again, but its not the right way of doing 
it.. In nv_close(), if you comment out the lines "nv_stop_rx(dev);" and "if 
(np->wolenabled) nv_start_rx(dev);", WOL works. 

However this isn't the right way to do it, which is why I haven't supplied a 
patch. What its supposed to do it stop receiving, clear any buffers, then 
restart receiving again. But this seems to break WOL for some reason. There 
must be some extra operation required for it all to work properly... I'll 
keep looking.

> OK, let me know if you need a guinea pig to test any patches you might
> have.
>
> Regards,
>
> Arjen
>
> On Tue, 20 Apr 2004, Andrew de Quincey wrote:
> > On Monday 19 April 2004 21:11, Arjen Verweij wrote:
> > > Hi,
> > >
> > > Is the wol support in forcedeth v25 complete yet? I was trying it with
> > > the 2.6.5 kernel it came with, tried the new forcedeth driver with a
> > > 2.6.3 kernel (because firewire seems broken in 2.6.5) however, my box
> > > will not wake up as of yet.
> >
> > You're right! It _was_ working with patch-forced-0.25, but it ain't in
> > 2.6.5. I'll see if I can spot the problem.
> >
> > > According to the source there is a FIXME with a comment about powering
> > > down the NIC. Does this mean that support for wol is incomplete for
> > > now? Mind you, I am just curious, this is in no way meant as criticism.
> >
> > That would only be for when WOL is NOT used; I think it has to leave the
> > NIC powered up for WOL to work... and as you say it ain't implemented
> > yet.
> >
> > > On another note, Carl-Daniel mentioned that DEV_NEED_TIMERIRQ might be
> > > removed from future releases. Is this still the case? Feedback would be
> > > much appreciated, so I can keep my humble audience up to date on what's
> > > going on at the wol front.
> > >
> > > Thank you guys for your excellent work,
> > >
> > > Arjen
> > > http://atlas.et.tudelft.nl/verwei90/nforce2/index.html
