From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Mon, 15 Oct 2012 12:04 +0200
Message-ID: <15188898.QK0YCDZ0MW@linux-lqwf.site>
References: <Pine.LNX.4.44L0.1210121126330.1605-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org, jkosina@suse.com
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57494 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727Ab2JOKFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2012 06:05:48 -0400
In-Reply-To: <Pine.LNX.4.44L0.1210121126330.1605-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 12 October 2012 11:29:49 Alan Stern wrote:
> On Fri, 12 Oct 2012, Oliver Neukum wrote:

> > First we have workqueues. bas-gigaset is a good example.
> > The driver kills a scheduled work in pre_reset(). If this is done synchronously
> > the driver may need to wait for a memory allocation inside the work.
> > In principle we could provide a workqueue limited to GFP_NOIO. Is that worth
> > it, or do we just check?
> 
> The work routine could set the GFP mask upon entry and exit.  Then a 
> separate workqueue wouldn't be needed.

Well, yes. But if we have to touch the code we might just as well use GFP-NOIO

> > I am afraid there is no generic solution in the last two cases. What do you think?
> 
> The other contexts must also set the GFP mask.  Unfortunately, this has 
> to be done case-by-case.

This raises a question. If we do the port-power-off stuff, does reset_resume() of every
device under the depowered port have to be called? If so, we cannot exclude vendor
specific drivers from the audit, can we?

	Regards
		Oliver
