From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: kernel 3.1.1 message:  <IRQ> warn_alloc_failed
Date: Tue, 13 Dec 2011 19:09:54 +0000
Message-ID: <1323803394.2790.5.camel@bwh-desktop>
References: <6.2.5.6.2.20111208210303.03a06228@flumedata.com>
	 <20111209095014.14a647cd@nehalam.linuxnetplumber.net>
	 <6.2.5.6.2.20111209130007.039b3078@binnacle.cx>
	 <13A253B3F9BEFE43B93C09CF75F63CAA8162593365@MNEXMB1.qlogic.org>
	 <20111213104152.14c01911@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	"starlight@binnacle.cx" <starlight@binnacle.cx>,
	Sony Chacko <sony.chacko@qlogic.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40646 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755104Ab1LMTJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 14:09:59 -0500
In-Reply-To: <20111213104152.14c01911@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-12-13 at 10:41 -0800, Stephen Hemminger wrote:
> On Tue, 13 Dec 2011 11:42:13 -0600
> Rajesh Borundia <rajesh.borundia@qlogic.com> wrote:
> 
> > Hi All,
> > 
> > Sorry for late reply.
> > 
> > Stephan,
> > Thanks for analyzing.
> > 
> > Yes, the netxen adapter does not support fragmented page memory.
> > They are not harmful messages. At that instant of time it may fail allocating
> > memory for some buffers in the ring but after enough memory is available
> > it will try to allocate memory for unallocated buffers in ring.
> > 
> > Or the other option could be to turn LRO off.
[...]
> The driver should be changed to call allocation with __GFP_NOWARN.
> Change dev_alloc_skb(size) to
>   __dev_alloc_skb(size, GFP_ATOMIC|__GFP_NOWARN)
> 
> Or better yet, switch to using netdev_alloc variant like
>   __netdev_alloc_skb_ip_align(dev, length, GFP_ATOMIC|__GFP_NOWARN)

Why should this be done only in specific drivers?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
