From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.1[78] page allocation failure. order:3, mode:0x20
Date: Fri, 22 Sep 2006 21:50:00 -0700
Message-ID: <20060922215000.c1fde093.akpm@osdl.org>
References: <Pine.LNX.4.64.0609220655550.13396@diagnostix.dwd.de>
	<20060922004253.2e2e2612.akpm@osdl.org>
	<4514190C.8010901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Holger Kiehl <Holger.Kiehl@dwd.de>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-net <linux-net@vger.kernel.org>, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:29154 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750933AbWIWEuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 00:50:07 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <4514190C.8010901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 10:10:36 -0700
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> I wonder if we can't account for NET_IP_ALIGN when selecting bufsize, to get at 
> rid of at least 1 order size before we netdev_alloc_skb. This should make 9k 
> frames only kmalloc(16384) and thus stay within the 16k boundary. I hope.
> 
> Completely untested: don't commit :)
> 

I did - I think we want this patch.

> 
> e1000: account for NET_IP_ALIGN when calculating bufsiz
> 
> Account for NET_IP_ALIGN when requesting buffer sizes from netdev_alloc_skb to 
> reduce slab allocation by half.

Could we please do whatever is needed to get this blessed and merged?  This
is such a common problem on such a common driver that I would suggest that
we want this in 2.6.18.x as well.  At least, I'd expect distributors to
ship this fix (they're nuts if they don't) and so it makes sense to deliver
it from kernel.org.
