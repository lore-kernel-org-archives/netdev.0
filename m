From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Wed, 20 Apr 2011 17:08:35 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1104201658280.1686-100000@iolanthe.rowland.org>
References: <20110420195015.20A96201B8@glenhelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, <linux-usb@vger.kernel.org>,
	<davem@davemloft.net>, <greg@kroah.com>
To: Paul Stewart <pstew@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:39746 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753492Ab1DTVIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 17:08:35 -0400
In-Reply-To: <20110420195015.20A96201B8@glenhelen.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Apr 2011, Paul Stewart wrote:

> Set a flag if the interrupt URB completes with ENOENT as this
> occurs legitimately during system suspend.  When the usbnet_bh
> is called after resume, test this flag and try once to resubmit
> the interrupt URB.

No doubt there's a good reason for doing things this way, but it isn't
clear.  Why wait until usbnet_bh() is called after resume?  Why not
resubmit the interrupt URB _during_ usbnet_resume()?  This would seem
to be the logical approach, seeing as how usbnet_suspend() kills the
interrupt URB.

For that matter, where does the interrupt URB get deallocated?  It 
obviously gets allocated in init_status(), but it doesn't seem to be 
freed anywhere.

Alan Stern

