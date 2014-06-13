From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] vxlan: use dev->needed_headroom instead of
 dev->hard_header_len
Date: Fri, 13 Jun 2014 15:29:26 -0700 (PDT)
Message-ID: <20140613.152926.1695048625021986920.davem@davemloft.net>
References: <1402599190-24350-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	pshelar@nicira.com, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbaFMW31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 18:29:27 -0400
In-Reply-To: <1402599190-24350-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 12 Jun 2014 11:53:10 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> When we mirror packets from a vxlan tunnel to other device,
> the mirror device should see the same packets (that is, without
> outer header). Because vxlan tunnel sets dev->hard_header_len,
> tcf_mirred() resets mac header back to outer mac, the mirror device
> actually sees packets with outer headers
> 
> Vxlan tunnel should set dev->needed_headroom instead of
> dev->hard_header_len, like what other ip tunnels do. This fixes
> the above problem.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: stephen hemminger <stephen@networkplumber.org>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

This looks good, and as you say consistent with how other IP tunnel
types are handled.

Applied, and queued up for -stable, thanks.
