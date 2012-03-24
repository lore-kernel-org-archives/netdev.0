From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Subject: Re: [PATCH v2] iwlwifi: fix skb truesize underestimation
Date: Sat, 24 Mar 2012 08:35:28 -0700
Message-ID: <1332603328.27767.11.camel@wwguy-huron>
References: <1332507112.4858.12.camel@edumazet-laptop>
	 <20120323.143826.1042705555491529895.davem@davemloft.net>
	 <1332528919.2516.2.camel@edumazet-glaptop>
	 <1332547547.2516.132.camel@edumazet-glaptop>
	 <1332548545.2516.134.camel@edumazet-glaptop>
	 <1332548986.2516.139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56363 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754204Ab2CXPga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Mar 2012 11:36:30 -0400
In-Reply-To: <1332548986.2516.139.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Fri, 2012-03-23 at 17:29 -0700, Eric Dumazet wrote:
> By default, iwlwifi uses order-1 pages (8 KB) to store incoming frames,
> but doesnt say so in skb->truesize.
> 
> This makes very possible to exhaust kernel memory since these skb evade
> normal socket memory accounting.
> 
> As struct ieee80211_hdr is going to be pulled before calling IP stack,
> there is no need to use dev_alloc_skb() to reserve NET_SKB_PAD bytes.
> alloc_skb() is ok in this driver, allowing more tailroom.
> 
> Pull beginning of frame in skb header, in the hope we can reuse order-1
> pages in the driver immediately for small frames and reduce their
> truesize to the minimum (linear skbs)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>
> Cc: "John W. Linville" <linville@tuxdriver.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---

Is it ok I pull your patch into our internal tree first for regression
testing, once the test is done, I will push your patch along with all
our other patches together to wireless-next(John Linville).

By doing so, first, we know the patch is not breaking any functionality
for all the devices(legacy/new), second, it is easier for us to sync-up
with all the other changes we are making now.

Thanks
Wey
