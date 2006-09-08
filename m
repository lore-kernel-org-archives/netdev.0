From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 data corruption (TSO ?)
Date: Fri, 08 Sep 2006 15:22:52 -0700
Message-ID: <1157754172.9584.14.camel@rh4>
References: <1551EAE59135BE47B544934E30FC4FC093FB19@NT-IRVA-0751.brcm.ad.broadcom.com>
 <9EAEC3B2-260E-444E-BCA1-3C9806340F65@kernel.crashing.org>
 <1157745256.5344.8.camel@rh4>
 <1157751962.31071.102.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Segher Boessenkool" <segher@kernel.crashing.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Linux Kernel list" <linux-kernel@vger.kernel.org>,
	"Paul Mackerras" <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:38919 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751171AbWIHWYv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 18:24:51 -0400
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>
In-Reply-To: <1157751962.31071.102.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-09-09 at 07:46 +1000, Benjamin Herrenschmidt wrote:

> The PowerPC writel has a full sync _after_ the write, mostly to prevent
> it from leaking out of a spinlock, and for ordering it vs. other
> writel's or readl's. It doesn't provide any ordering guarantee vs
> cacheable storage (and was never intended to do so afaik). Such ordering
> shall
> be provided explicitely. It's possible that 2.4 used a big hammer
> approach but we've since been actively fixing drivers for that. It's to
> be noted that PowerPC might not be the only architecture affected as I
> don't think that in general, you have ordering guarantees between
> cacheable and non-cacheable stores unless you use explicit barriers.

I think 2.4 might have an additional sync before the write which will
guarantee that the buffer descriptor is written before telling the chip
to DMA it.

> 
> Thus I disagree with "fixing" the powerpc writel(). The barries shall
> definitely go into tg3.
> 

You'll have to take this up with David.

