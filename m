From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bridge: check the length of skb after
 nf_bridge_maybe_copy_header()
Date: Fri, 31 Dec 2010 11:10:03 -0800 (PST)
Message-ID: <20101231.111003.48499853.davem@davemloft.net>
References: <1293284490-17114-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60289
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751622Ab0LaTJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 14:09:33 -0500
In-Reply-To: <1293284490-17114-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sat, 25 Dec 2010 21:41:30 +0800

> Since nf_bridge_maybe_copy_header() may change the length of skb,
> we should check the length of skb after it to handle the ppoe skbs.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

This is really strange.

packet_length() subtracts VLAN_HLEN from the value it returns, so the
correct fix seems to be to make this function handle the PPPOE case
too.

Otherwise I suspect you have many other functions to fix as well.

I'm not applying this patch.
