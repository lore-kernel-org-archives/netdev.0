From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] rtnl_unlock cleanups
Date: Wed, 10 Oct 2007 21:13:06 -0700 (PDT)
Message-ID: <20071010.211306.108746295.davem@davemloft.net>
References: <20071005144414.GA7050@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43005
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751137AbXJKEND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 00:13:03 -0400
In-Reply-To: <20071005144414.GA7050@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 5 Oct 2007 18:44:14 +0400

> There is no need to process outstanding netlink user->kernel packets
> during rtnl_unlock now. There is no rtnl_trylock in the rtnetlink_rcv
> anymore.
> 
> Normal code path is the following:
> netlink_sendmsg
>    netlink_unicast
>        netlink_sendskb
>            skb_queue_tail
>            netlink_data_ready
>                rtnetlink_rcv
>                    mutex_lock(&rtnl_mutex);
>                    netlink_run_queue(sk, qlen, &rtnetlink_rcv_msg);
>                    mutex_unlock(&rtnl_mutex);
> 
> So, it is possible, that packets can be present in the rtnl->sk_receive_queue
> during rtnl_unlock, but there is no need to process them at that moment as
> rtnetlink_rcv for that packet is pending.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied.
