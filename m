From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] make netlink user -> kernel interface synchronious
Date: Fri, 05 Oct 2007 18:24:27 +0200
Message-ID: <4706653B.3050000@trash.net>
References: <20071005144844.GA7119@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	devel@openvz.org, containers@lists.osdl.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52787 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757497AbXJEQZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 12:25:45 -0400
In-Reply-To: <20071005144844.GA7119@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis V. Lunev wrote:
> This patch make processing netlink user -> kernel messages synchronious.
> This change was inspired by the talk with Alexey Kuznetsov about current
> netlink messages processing. He says that he was badly wrong when introduced 
> asynchronious user -> kernel communication.
> 
> The call netlink_unicast is the only path to send message to the kernel
> netlink socket. But, unfortunately, it is also used to send data to the
> user.
> 
> Before this change the user message has been attached to the socket queue
> and sk->sk_data_ready was called. The process has been blocked until all
> pending messages were processed. The bad thing is that this processing
> may occur in the arbitrary process context.
> 
> This patch changes nlk->data_ready callback to get 1 skb and force packet
> processing right in the netlink_unicast.


I guess the process credential stuff in netlink_skb_params can now
be removed as well.
