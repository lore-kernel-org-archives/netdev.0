From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip_tunnel: Fix dst ref-count.
Date: Mon, 24 Mar 2014 15:24:12 -0400 (EDT)
Message-ID: <20140324.152412.1501867662024898167.davem@davemloft.net>
References: <1395637596-28064-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lucien.xin@gmail.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753776AbaCXTYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 15:24:14 -0400
In-Reply-To: <1395637596-28064-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin <pshelar@nicira.com>
Date: Sun, 23 Mar 2014 22:06:36 -0700

> Commit 10ddceb22ba (ip_tunnel:multicast process cause panic due
> to skb->_skb_refdst NULL pointer) removed dst-drop call from
> ip-tunnel-recv.
> 
> Following commit reintroduce dst-drop and fix the original bug by
> checking loopback packet before releasing dst.
> Original bug: https://bugzilla.kernel.org/show_bug.cgi?id=70681
> 
> CC: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

I don't understand why only the GRE tunnel implementation needs the
check, whereas ipip and sit seem to have the same code associated
paths.

Plus I think this is incredibly sloppy, making the implementations
have to attend to this detail.  Why the heck do we have a common
piece of infrastructure if we end up with all of this duplicated
code anyways?

Put this check somewhere common, so that we are guaranteed that the
issue is really fixed for all tunnel types, no matter what.

Thanks.
