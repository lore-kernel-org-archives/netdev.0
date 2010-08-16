From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Mon, 16 Aug 2010 08:22:33 +0200
Message-ID: <1281939753.3683.5.camel@jlt3.sipsolutions.net>
References: <1281710115.3760.27.camel@jlt3.sipsolutions.net>
	 <1281710887.4470.78.camel@edumazet-laptop>
	 <1281712433.2116.15.camel@jlt3.sipsolutions.net>
	 <20100814.223722.116371746.davem@davemloft.net>
	 <1281936351.3683.1.camel@jlt3.sipsolutions.net>
	 <1281939002.2942.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:56604 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab0HPGWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 02:22:36 -0400
In-Reply-To: <1281939002.2942.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-16 at 08:10 +0200, Eric Dumazet wrote:

> We'll find another way to address the problem.

For my understanding: The problem is that the save/restore of the
frag_list skb can race so a second reader will not see the frag_list skb
because it gets there while it's NULL. This happens with MSG_PEEK, or
with clones of the SKB since skb_shared_info is invariant across clones.

Correct?

johannes

