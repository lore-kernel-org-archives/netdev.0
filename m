From: Greg KH <gregkh@suse.de>
Subject: Re: 2.6.21-rc7: BUG: sleeping function called from invalid context
	at net/core/sock.c:1523
Date: Sun, 13 May 2007 02:20:52 -0700
Message-ID: <20070513092052.GA11249@suse.de>
References: <462D1B09.9050005@goop.org> <Pine.LNX.4.64.0704232257090.20657@twin.jikos.cz> <Pine.LNX.4.64.0704261625410.20657@twin.jikos.cz> <a781481a0705110629n7c7130c1x3a89fa958b271f20@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <jikos@jikos.cz>,
	Marcel Holtmann <marcel@holtmann.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>, maxk@qualcomm.com,
	bluez-devel@lists.sourceforge.net,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:33042 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759687AbXENBmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2007 21:42:24 -0400
Content-Disposition: inline
In-Reply-To: <a781481a0705110629n7c7130c1x3a89fa958b271f20@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 06:59:31PM +0530, Satyam Sharma wrote:
>  [1] This is the first problem point. However, I didn't find any reason
>  why this particular driver's .disconnect() couldn't sleep. In fact, a
>  comment in include/linux/usb.h:811 says:
> 
>  "The probe() and disconnect() methods are called in a context where
>  they can sleep, but they should avoid abusing the privilege. Most
>  work to connect to a device should be done when the device is opened,
>  and undone at the last close. The disconnect code needs to address
>  concurrency issues with respect to open() and close() methods, as
>  well as forcing all pending I/O requests to complete (by unlinking
>  them as necessary, and blocking until the unlinks complete)."
> 
>  I'm assuming the comment is not obsolete, of course, but although the
>  first sentence says .disconnect() shouldn't abuse the privilege to
>  sleep, the last sentence makes it quite evident that we are _allowed_
>  to do so anyway, and that is how things are (with the hci_usb driver,
>  at least, I didn't check the .remove() or .disconnect() functions of other
>  USB drivers, however).

Yes, this is true, you are running in thread context for .disconnect of
usb drivers, so you can sleep if you need to, but you will block all
other device's disconnect and probe functions while you do.  So, it's
good to try to not abuse this if possible.

thanks,

greg k-h
