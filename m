From: Nathan Williams <nathan@traverse.com.au>
Subject: Re: [PATCH] br2684: don't send frames on not-ready vcc
Date: Fri, 30 Nov 2012 12:18:05 +1100
Message-ID: <1354238285.3128.273.camel@dualcore.traverse>
References: <1354058916.2534.25.camel@shinybook.infradead.org>
	 <20121128.114153.737074131307295783.davem@davemloft.net>
	 <1354122070.21562.89.camel@shinybook.infradead.org>
	 <20121128.120415.778262714601372592.davem@davemloft.net>
	 <1354122555.21562.92.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chas@cmf.nrl.navy.mil,
	krzysiek@podlesie.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:49436 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755407Ab2K3BSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 20:18:08 -0500
In-Reply-To: <1354122555.21562.92.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-28 at 17:09 +0000, David Woodhouse wrote:
> On Wed, 2012-11-28 at 12:04 -0500, David Miller wrote:
> > Do you want me to pull that tree into net-next or is there a plan to
> > repost the entire series of work for a final submission?
> 
> I think it needs a little more testing/consensus first. I'd like an ack
> from Chas on the atm ->release_cb() thing, at least. And I wouldn't mind
> confirmation from Nathan's customer that they're no longer seeing the
> panics.
> 

The customer has confirmed that they haven't seen any panics.  I tested
these patches on OpenWrt with Kernel 3.3.8 and couldn't get a panic:

c118dc5 solos-pci: Fix leak of skb received for unknown vcc
e539793 br2684: fix module_put() race
3656320 br2684: don't send frames on not-ready vcc
753f920 solos-pci: Wait for pending TX to complete when releasing vcc
91ab2cf pppoatm: do not inline pppoatm_may_send()
85b48fa pppoatm: drop frames to not-ready vcc
3ac1080 pppoatm: take ATM socket lock in pppoatm_send()
e41faed pppoatm: fix module_put() race
3b1a914 pppoatm: allow assign only on a connected socket
ec809bd atm: add owner of push() callback to atmvcc
ae088d6 atm: br2684: Fix excessive queue bloat

I haven't tested these ones:

230a012 pppoatm: fix missing wakeup in pppoatm_send()
1c0c800 atm: Add release_cb() callback to vcc
