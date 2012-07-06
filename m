From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel paging request at 00000000d8be176d
Date: Thu, 05 Jul 2012 23:44:13 -0700 (PDT)
Message-ID: <20120705.234413.823095842284954048.davem@davemloft.net>
References: <20120706055859.GA27693@localhost>
	<1341555227.3265.54.camel@edumazet-glaptop>
	<1341556907.3265.93.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfg@linux.intel.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab2GFGoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 02:44:14 -0400
In-Reply-To: <1341556907.3265.93.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jul 2012 08:41:47 +0200

> David, what do you think if I submit a patch using following accessor ?
> 
> /* get a rt6_info given a dst_entry pointer */
> static inline struct rt6_info *dst_rt6_info(struct dst_entry *dst)
> {
> 	return (struct rt6_info *)dst;
> }

I'd rather we simply not use address-of pointers in our interfaces
like we do now in some spots.

99 times out of 100 it's a case where PTR_ERR() would do.

I spent a lot of time moving both ipv4 and ipv6 in this direction,
we're almost there, and should simply finish off the remaining
cases.
