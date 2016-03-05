From: Oliver Neukum <oneukum@suse.com>
Subject: Re: Possible double-free in the usbnet driver
Date: Sat, 05 Mar 2016 16:51:30 +0100
Message-ID: <1457193090.8935.7.camel@suse.com>
References: <CA+55aFxqwjs5gs6Fw2jmTteWM4hZTnr7Ls111ExNTieObLs82Q@mail.gmail.com>
	 <CA+fCnZfS51F7WZEM1YTSPDMWSzvBTJWGf5cRWv5LrNCSOf_-qA@mail.gmail.com>
	 <CA+55aFwxbs_hLG58Q_xSK2vpufjmwMk-xkqxTNh_5h-A8y4vbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Konovalov <andreyknvl@gmail.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Alexander Potapenko <glider@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	USB list <linux-usb@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40407 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422AbcCEPyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2016 10:54:15 -0500
In-Reply-To: <CA+55aFwxbs_hLG58Q_xSK2vpufjmwMk-xkqxTNh_5h-A8y4vbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-04 at 14:43 -0800, Linus Torvalds wrote:

> So you have usbnet_defer_kevent() getting triggered, which in turn
> ends up using "usbnet->kevent"
> 
> But somebody like Oliver is really the right person to check this. For
> example, it's entirely possible that we should just instead do
> 
>         cancel_work_sync(&dev->kevent);
> 
> before the "free_netdev(net)" in the "out1" label.

Hi Bjorn,

I thinbk Linus has analyzed this correctly, but the fix really needs
to cancel the work, because we can also fail later after bind() has
already run. However, still cdc-ncm and the other drivers should clean
up after themselves if bind() fails, as usbnet really cannot known what
the subdrivers have done.

So in conclusion, I think Linus' fix should also go into cdc-ncm.

	Regards
		Oliver
