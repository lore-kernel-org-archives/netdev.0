From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v2] netfilter: Xtables: idletimer target implementation
Date: Thu, 03 Jun 2010 13:13:01 +0300
Message-ID: <1275559981.10855.141.camel@chilepepper>
References: <1275486062-23753-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1006021708370.27340@obet.zrqbmnf.qr>
	 <1275503835.1574.0.camel@powerslave> <1275505553.2797.2.camel@powerslave>
	 <alpine.LSU.2.01.1006022127430.32028@obet.zrqbmnf.qr>
	 <1275508348.2797.26.camel@powerslave> <1275509088.2797.29.camel@powerslave>
	 <1275512485.2797.46.camel@powerslave>
	 <1275548660.10855.4.camel@chilepepper>
	 <alpine.LSU.2.01.1006030956000.9308@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:56706 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933425Ab0FCKTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:19:51 -0400
In-Reply-To: <alpine.LSU.2.01.1006030956000.9308@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-03 at 09:58 +0200, ext Jan Engelhardt wrote:
> On Thursday 2010-06-03 09:04, Luciano Coelho wrote:
> >
> >Looking closer, it seems that it makes a bit of sense to add a kernel
> >module to /sys/device/system.  I think it makes more sense than adding
> >to the module class or to the net class, actually.  The idletimer is not
> >a net device (so it doesn't fit in /sys/class/net) and it is not a
> >module, even though it may be handled by the xt_IDLETIMER module.
> >
> >So we can look at the xt_idletimer as a system device, which is not a
> >peripheral device in itself, but a software timer device (there are
> >already similar components).
> >
> >I'll add the kernel object we need as a system class device, so it will
> >go under /sys/devices/system/xt_idletimer.  Does that make sense to you?
> 
> Mh.. somehow I'd pick /sys/devices/virtual/xt_idletimer.
> Or even create a /sys/net/xt_idletimer. (/sys has conceptual
> subsystems directly beneath it: devices, fs, kernel, ...)

Yes, I think I'll use the /sys/device/virtual/misc class.  That seems to
be the place where, well, miscellaneous devices go. :) I think it fits
pretty nicely in that concept.

We could also have a /sys/net subsystem, but that's very high in the
sysfs hierarchy and adding it in the xt_IDLETIMER module wouldn't make
any sense.  This is something that should be added (if really needed) in
the net core subsystem, I guess.

I'll use the first option and resubmit the patch as v3.


-- 
Cheers,
Luca.

