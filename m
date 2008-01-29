From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Udev coldplugging loads 8139too driver instead of 8139cp
Date: Mon, 28 Jan 2008 17:08:30 -0800
Message-ID: <20080128170830.6f67fa5a@deepthought>
References: <1201554992.13883.13.camel@Anastacia>
	<479E7750.9060304@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:37371 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751785AbYA2BIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 20:08:42 -0500
In-Reply-To: <479E7750.9060304@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jan 2008 03:46:08 +0300
Michael Tokarev <mjt@tls.msk.ru> wrote:

> Frederik Himpe wrote:
> > Linux 2.6.24 kernel gives the following messages when udev coldplugging
> > loads the driver for my NIC:
> > 
> > 8139too 0000:00:0b.0: This (id 10ec:8139 rev 20) is an enhanced 8139C+ chip
> > 8139too 0000:00:0b.0: Use the "8139cp" driver for improved performance and stability.
> 
> There are 2 drivers for 8139-based NICs.  For really different two kinds
> of hardware, which both uses the same PCI identifiers.  Both drivers
> "claims" to work with all NICs with those PCI ids, because "externally"
> (by means of udev for example) it's impossible to distinguish the two
> kinds of hardware, it becomes clean only when the driver (either of the
> two) loads and actually checks which hardware we have here.

Is there any chance of using subdevice or subversion to tell them apart?
That worked for other vendors like DLINK who slapped same ID on different
cards.

> Udev in fact loads both - 8139cp and 8139too.  The difference is the ORDER
> in which it loads them - if for "cp-handled" hardware it first loads "too",
> too will complain as above and will NOT claim the device.  The same is
> true for the opposite.
> 
> So - in short - things has always been this way (thanks to realtec).
> I've seen similar (but opposite) effects on my systems, which are all
> should be serviced by 8139too driver but 8139cp loaded first - up
> till i gave up and just disabled 8139cp...
> 
> I don't know what happened in 2.6.24, but my guess is that since 8139too-based
> hw is now alot more common, the two drivers are listed in the opposite
> order.
> 
> In short: NotABug, or ComplainToRealtec (but that's waaaay too late and
> will not help anyway) ;)
> 
> /mjt
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
