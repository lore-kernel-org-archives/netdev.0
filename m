From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate
 module unloading
Date: Thu, 15 Aug 2013 10:13:14 -0700
Message-ID: <20130815171314.GB30547@kroah.com>
References: <20130814163311.GB7208@kroah.com>
 <20130815084221.3339142f@mitra.spranger.biz>
 <20130815065936.GA13320@kroah.com>
 <20130815092753.5a23810b@mitra.spranger.biz>
 <20130815080901.GC7080@kroah.com>
 <520C8EC9.6040603@linutronix.de>
 <20130815155508.GA14792@kroah.com>
 <520CFBE0.5070006@linutronix.de>
 <20130815164227.GC15688@kroah.com>
 <520D07D6.70407@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benedikt Spranger <b.spranger@linutronix.de>,
	netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:39314 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758246Ab3HORLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 13:11:39 -0400
Content-Disposition: inline
In-Reply-To: <520D07D6.70407@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 06:54:46PM +0200, Sebastian Andrzej Siewior wrote:
> On 08/15/2013 06:42 PM, Greg Kroah-Hartman wrote:
> >> For this to happen you would need a refcount in uio-core which learns
> >> that the device is gone and does not invoke any callbacks because the
> >> device is gone. Something like you have in USB where you return 0 on
> >> reads from ttyUSB after someone pulled the cable.
> > 
> > That happens because we invalidate the filehandle in the tty layer by
> > tearing everything down in the usb serial driver.  And yes, uio also
> > needs to do the same thing, if it doesn't already.
> 
> Ah. Do you have a handy pointer where / how you do this?

The tty layer isn't exactly "handy" :)

Somewhere we send a HANGUP signal to userspace, and I think we
invalidate the file handle somehow, it's been years since I last looked
at that code, sorry.

greg k-h
