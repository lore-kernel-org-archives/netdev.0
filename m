From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Cache source address in nexthop entries.
Date: Tue, 15 Mar 2011 16:02:19 -0700 (PDT)
Message-ID: <20110315.160219.189709250.davem@davemloft.net>
References: <20110308.103801.193702247.davem@davemloft.net>
	<20110308.110352.189704727.davem@davemloft.net>
	<alpine.LFD.2.00.1103151135110.1729@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38595
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751418Ab1COXBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 19:01:42 -0400
In-Reply-To: <alpine.LFD.2.00.1103151135110.1729@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 15 Mar 2011 12:00:33 +0200 (EET)

> 	I see another problem with nh_saddr. fib_info
> is reused when NHs and some parameters are equal but the
> scope is not part of the fib_info and it is wrong to cache
> route scope in NH or even in fib_info. The problem is
> that we can expose in nh_saddr addresses with wrong
> scope for the route. It happens when two routes with
> different route scope reuse same fib_info.
> 
> 	First thought is that the field fa_scope can be
> moved into fib_scope in struct fib_info, not to use
> nh_cfg_scope. Then fib_find_info can differentiate the
> entries by fib_scope. It means, fib_info will not be reused
> if fib_scope is different. For FIB_RES_PREFSRC I assume we
> can access fib_info from nh->nh_parent safely when
> refreshing nh_saddr.
> 
> 	Here is a script that demonstrates the wrong
> exposing:

Thanks for all of your feedback Julian, I will look into
this very soon.
