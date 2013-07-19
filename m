From: David Miller <davem@davemloft.net>
Subject: Re: [DISCUSSION] rt6i_genid
Date: Fri, 19 Jul 2013 02:33:18 -0700 (PDT)
Message-ID: <20130719.023318.2201887768706444746.davem@davemloft.net>
References: <51E8B273.1090002@windriver.com>
	<20130718.203100.1960741588589171145.davem@davemloft.net>
	<51E8EFBC.6040902@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759890Ab3GSJdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 05:33:20 -0400
In-Reply-To: <51E8EFBC.6040902@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Fri, 19 Jul 2013 15:50:20 +0800

> The original commit is targeted for XFRM policy inserting/removing,
> but it uses net genid shared by both IPv4 and IPv6, the side effect is
> add/delete IPv4 address will invalidate IPv6 dst in all.
> 
> We *do* need to bump genid when add/delete IPv6 address in scenario I
> described here: http://www.spinics.net/lists/netdev/msg243398.html,
> but definitely not from add/delete IPv4 address. Moreover test shows
> that DCCP still push thousands of packets on wire after delete its
> IPv6
> address in the same scenario I describe before.
> 
> The impulse to bump genid for IPv6 is much more stronger after this
> commit even do it unintentionally.

If you really think it will help, and it will still handle the IPSEC
case, you can make a seperate genid for ipv4 and ipv6 but that might not
work out so cleanly.
