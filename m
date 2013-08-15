From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate
 module unloading
Date: Wed, 14 Aug 2013 23:59:36 -0700
Message-ID: <20130815065936.GA13320@kroah.com>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
 <1376384922-8519-3-git-send-email-b.spranger@linutronix.de>
 <20130813174814.GE4098@kroah.com>
 <20130814091946.2643a124@mitra.spranger.biz>
 <20130814163311.GB7208@kroah.com>
 <20130815084221.3339142f@mitra.spranger.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:59463 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757891Ab3HOG6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 02:58:02 -0400
Content-Disposition: inline
In-Reply-To: <20130815084221.3339142f@mitra.spranger.biz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 08:42:21AM +0200, Benedikt Spranger wrote:
> On Wed, 14 Aug 2013 09:33:11 -0700
> Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> > Step 4 should have told UIO that it was gone and had it shut everything
> > down properly, so that there would not be a crash.
> The MFD driver only knows about a specific MFD cell. Through
> enable/disable callbacks the driver could tell UIO ...hm... whom? what?
> 
> Neither the MFD driver nor the MFD core knows something about a specific
> UIO driver. But only that specific UIO driver knows about the device
> node activities. 
> 
> > > > You shouldn't need a module reference for this type of thing.
> > > The driver uio_pdrv has no chance to recognize that the underlaying platform
> > > device has gone.
> > The mfd driver could tell it that it is gone, right?
> It could tell, but whom and how?

Hm.  Ah, doesn't this work like PCI, when a PCI device is removed from
the system, reads just start returning all 0xFF, so the userspace UIO
driver now knows the device is gone from the system.  Doesn't MFD
hardware work the same way?  Why would removing the MFD driver affect
UIO at all, as it's just an interrupt and memory, both of which are
controlled by UIO, not MFD at all.

confused,

greg k-h
