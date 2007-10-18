From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Lost locking in fl6_sock_lookup
Date: Thu, 18 Oct 2007 05:14:26 -0700 (PDT)
Message-ID: <20071018.051426.102573633.davem@davemloft.net>
References: <47174950.6060409@openvz.org>
	<20071018.210043.51908349.yoshfuji@linux-ipv6.org>
	<47174D8E.2050200@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51571
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763151AbXJRMON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 08:14:13 -0400
In-Reply-To: <47174D8E.2050200@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 18 Oct 2007 16:11:58 +0400

> YOSHIFUJI Hideaki wrote:
> > In article <47174950.6060409@openvz.org> (at Thu, 18 Oct 2007 15:53:52 +0400), Pavel Emelyanov <xemul@openvz.org> says:
> > 
> >> This routine scans the ipv6_fl_list whose update is
> >> protected with the socket lock and the ip6_sk_fl_lock.
> > 
> >>  		struct ip6_flowlabel *fl = sfl->fl;
> >>  		if (fl->label == label) {
> >> +			read_unlock_bh(&ip6_sk_fl_lock);
> >>  			fl->lastuse = jiffies;
> >>  			atomic_inc(&fl->users);
> >>  			return fl;
> > 
> > We should increment fl->users within the critical section, shouldn't we?
> 
> Not necessary. The users is more than zero (because it is 
> linked in the sock's list) so garbage collector won't catch 
> it in any way.

Right, we're grabbing an "extra" reference here and only
someone who gets the socket lock (which we have) can unlink
it and thus potentially drop the count to zero.
