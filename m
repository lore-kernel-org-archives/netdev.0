From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Sat, 05 Jul 2008 13:42:59 +0100
Message-ID: <1215261779.10393.829.camel@pmac.infradead.org>
References: <486E2260.5050503@garzik.org>
	 <1215178035.10393.763.camel@pmac.infradead.org>
	 <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de>
	 <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org>
	 <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de>
	 <20080705105317.GA44773@dspnet.fr.eu.org> <486F596C.8050109@firstfloor.org>
	 <20080705120221.GC44773@dspnet.fr.eu.org> <486F6494.8020108@firstfloor.org>
	 <1215260166.10393.816.camel@pmac.infradead.org>
	 <486F67B7.9040304@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Olivier Galibert <galibert@pobox.com>,
	Takashi Iwai <tiwai@suse.de>, Hannes Reinecke <hare@suse.de>,
	Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>, hugh@veritas.com,
	akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:40661 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbYGEMn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2008 08:43:27 -0400
In-Reply-To: <486F67B7.9040304@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-07-05 at 14:23 +0200, Andi Kleen wrote:
> That's a lot of "should" and "in most cases" and "in a ideal world".

OK, let's phrase it differently:

It almost never happens, and it's trivial to handle it safely in the
extremely rare cases that it does. We don't need to start putting
firmware in /lib/firmware/`uname -r`/ to deal with it.

>  What happens when the new firmware is buggy for example and prevents
> booting of the system?

If the firmware is required for booting the system, then it'll be
included in the initramfs. The one on the _real_ file system is
therefore irrelevant. When you select the last-known-good kernel from
your boot loader you'll actually get the old firmware anyway.

And given that we almost never update most of this firmware _either_, it
really isn't a problem we should be losing sleep over.

But distributors are free to shift it into /lib/firmware/`uname -r`/ if
they want to -- it's easy enough to override INSTALL_FW_PATH. For now,
though, that isn't compatible with upstream hotplug scripts and would be
a bad choice as a default.

And if a distribution which actually likes contributing its changes
upstream ever starts using /lib/firmware/`uname -r`/, then perhaps we
can discuss making it the default for the kernel too.

-- 
dwmw2

