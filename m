From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Sun, 6 Jul 2008 21:57:11 -0700
Message-ID: <20080706215711.135a8524@infradead.org>
References: <487176A2.6080604@cn.fujitsu.com>
	<20080706.205905.159207367.davem@davemloft.net>
	<20080706213427.406e8f29@infradead.org>
	<20080706.214915.255106355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39874 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbYGGE5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 00:57:20 -0400
In-Reply-To: <20080706.214915.255106355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 06 Jul 2008 21:49:15 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Arjan van de Ven <arjan@infradead.org>
> Date: Sun, 6 Jul 2008 21:34:27 -0700
> 
> > On Sun, 06 Jul 2008 20:59:05 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > 
> > > Also correct.
> > 
> > ok updated version below; I also added an explicit comment for the
> > ethtool locking
> > 
> > From: Arjan van de Ven <arjan@linux.intel.com>
> > Subject: Use WARN_ONCE() in the netdev timeout handler (and print
> > module name)
> 
> I'm basically fine with these changes.
> 
> But plain WARN() and WARN_ONCE() are not in any tree I am maintaining
> at the moment, so I really can't add it to net-next-2.6 or net-2.6
> even if I wanted to.

one option is that I carry this patch in the WARN tree (which I plan to
submit for -next tomorrow)
> 
> Do you really need this dependency?

Well I could split it in two, first add this just to the printk
and then have a second patch to turn it into a WARN().

I do need the later; the reason is lame but simple: the kerneloops
collection client, for privacy reasons, only sends the actual warning,
not random printk's around it. WARN() puts the printk inside the
warning so it'll be picked up as part of the whole, rather than not
being picked up as something probably unrelated.



-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
