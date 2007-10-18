From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/3] Lost locking in fl6_sock_lookup
Date: Thu, 18 Oct 2007 21:00:43 +0900 (JST)
Message-ID: <20071018.210043.51908349.yoshfuji@linux-ipv6.org>
References: <47174950.6060409@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, devel@openvz.org,
	yoshfuji@linux-ipv6.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34514 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762975AbXJRMAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 08:00:47 -0400
In-Reply-To: <47174950.6060409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <47174950.6060409@openvz.org> (at Thu, 18 Oct 2007 15:53:52 +0400), Pavel Emelyanov <xemul@openvz.org> says:

> This routine scans the ipv6_fl_list whose update is
> protected with the socket lock and the ip6_sk_fl_lock.

>  		struct ip6_flowlabel *fl = sfl->fl;
>  		if (fl->label == label) {
> +			read_unlock_bh(&ip6_sk_fl_lock);
>  			fl->lastuse = jiffies;
>  			atomic_inc(&fl->users);
>  			return fl;

We should increment fl->users within the critical section, shouldn't we?

--yoshfuji
