From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by
 ISDN
Date: Mon, 8 Oct 2007 10:39:02 -0700
Message-ID: <20071008103902.1fc6ff7c@freepuppy.rosehill>
References: <20071007120653.GA16184@rhlx01.hs-esslingen.de>
	<20071008114844.GB11453@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: Karsten Keil <kkeil@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48735 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751653AbXJHRkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 13:40:40 -0400
In-Reply-To: <20071008114844.GB11453@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 8 Oct 2007 13:48:44 +0200
Karsten Keil <kkeil@suse.de> wrote:

> On Sun, Oct 07, 2007 at 02:06:53PM +0200, Andreas Mohr wrote:
> > [not necessarily a very recent regression, used 2.6.19 kernels before...]
> > 
> > Hi all,
> > 
> > wondered why my main internet server (headless!) didn't come up properly
> > on a new 2.6.23-rc8-mm2
> ...
> > as if it's the
> >        BUG_ON(!dev->nd_net);
> > check which caused the BUG message.
> 
> The regression comes from the net namespace patches.
> Up to now in ISDN the struct netdevice is contained in struct isdn_net_dev and so
> it's not allocated using alloc_netdev(), which would set the missing dev->nd_net
> pointer.
> 
> 

Then ISDN is BROKEN in existing code.  ALL network devices must be allocated
by alloc_netdev() not the device driver otherwise there is no way to prevent
oopsing through sysfs. RTFM Documentation/networking/netdevices.txt

Please fix for 2.6.23 and 2.6.22 stable.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
