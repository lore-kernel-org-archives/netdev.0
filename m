From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH 1/1] drivers/net/usb/usbnet.c: No need for usb_free_urb
 in rx_complete
Date: Sat, 3 Sep 2011 16:02:26 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1109031559300.29295-100000@netrider.rowland.org>
References: <1315071353-14978-1-git-send-email-consul.kautuk@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver Neukum <oneukum@suse.de>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netrider.rowland.org ([192.131.102.5]:46259 "HELO
	netrider.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751846Ab1ICUC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 16:02:27 -0400
In-Reply-To: <1315071353-14978-1-git-send-email-consul.kautuk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 Sep 2011, Kautuk Consul wrote:

> usb_hcd_giveback_urb frees the urb irrespective of any return
> value from the urb->complete function. It calls usb_put_urb which 
> is #defined to usb_free_urb, so maybe we shouldn't be freeing this 
> from rx_complete.

usb_free_urb() doesn't free its argument unless the refcount drops to 
0.  The refcount is incremented during usb_hcd_submit_urb(), and the 
decrement during usb_hcd_giveback_urb() merely undoes this increment.

> But I can't get around the fact that this has not been detected as a problem 
> till now, so I could be quite wrong about this. :)

Quite probably.  :-)

Alan Stern
