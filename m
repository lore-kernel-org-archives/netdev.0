From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] skb truesize last offenders
Date: Fri, 23 Mar 2012 14:38:26 -0400 (EDT)
Message-ID: <20120323.143826.1042705555491529895.davem@davemloft.net>
References: <1332507112.4858.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wey-yi.w.guy@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab2CWSic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 14:38:32 -0400
In-Reply-To: <1332507112.4858.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 23 Mar 2012 05:51:52 -0700

> iwlwifi and some other users of skb_add_rx_frag() lie about skb
> truesize, because of API being lazy.
> 
> iwlwifi can use order-0 or order-1 pages and skb truesize is wrong.
> network sbs can use uncharged kernel memory and eventually crash machine
> in OOM.
> 
> I plan : 
> 
> 1) adding a @truesize parameter to skb_add_rx_frag() in a neutral patch
> 
> 2) fix drivers that dont charge the real size of fragment
> 
> 3) niu could then use skb_add_rx_frag() instead of custom code.

No objections from me.  But we really have to fix that
tcp_grow_window() issue, it's quite urgent if you ask me.
