From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: alloc skb based on a given data buffer
Date: Tue, 15 Sep 2009 16:57:29 +0800
Message-ID: <1253005050.7549.58.camel@debian>
References: <1252897270.5650.169.camel@debian>
	 <20090914130612.GA11778@csn.ul.ie>	<1253003420.7549.51.camel@debian>
	 <20090915.013321.07006714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "mel@csn.ul.ie" <mel@csn.ul.ie>,
	"Chatre, Reinette" <reinette.chatre@intel.com>,
	"elendil@planet.nl" <elendil@planet.nl>,
	"Larry.Finger@lwfinger.net" <Larry.Finger@lwfinger.net>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"penberg@cs.helsinki.fi" <penberg@cs.helsinki.fi>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ipw3945-devel@lists.sourceforge.net"
	<ipw3945-devel@lists.sourceforge.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"cl@linux-foundation.org" <cl@linux-foundation.org>,
	"Krauss, Assaf" <assaf.krauss@intel.com>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"Abbas, Mohamed" <mohamed.abbas@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64475 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbZIOI5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 04:57:31 -0400
In-Reply-To: <20090915.013321.07006714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-09-15 at 16:33 +0800, David Miller wrote:
> From: Zhu Yi <yi.zhu@intel.com>
> Date: Tue, 15 Sep 2009 16:30:20 +0800
> 
> > This way, device drivers can allocate the Rx buffers with their own size
> > and alignment requirement. i.e. do an order-1 page allocation directly
> > with free_pages() in the iwlagn driver for a 256 bytes aligned 8K Rx
> > buffer. After DMA is finished, drivers can use the above function to
> > assemble an skb based on the Rx buffer. It should resolve the problem
> > for requiring an order-2 allocation by alloc_skb() in the first place.
> 
> You can create paged RX skbs just like drivers such as niu.c
> and others already do, there is no need for special APIs for
> this.

Thanks. So we can put the 8K buffer into 2 skb_shinfo()->frags[] slots
and set nr_frags to 2, right? Is this supported allover the network code
already? At a first glance, I didn't find any frags handling in mac80211
stack.

Thanks,
-yi

