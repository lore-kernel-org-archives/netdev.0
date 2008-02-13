From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Reorder ACK/RST checking in LISTEN state
Date: Tue, 12 Feb 2008 23:08:24 -0800 (PST)
Message-ID: <20080212.230824.263037704.davem@davemloft.net>
References: <47B29055.8060409@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: katterjohn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60834
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764806AbYBMHHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 02:07:52 -0500
In-Reply-To: <47B29055.8060409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kris Katterjohn <katterjohn@gmail.com>
Date: Wed, 13 Feb 2008 00:38:13 -0600

> I've attached a patch that changes the order of the ACK and RST checking 
> in the LISTEN state in tcp_rcv_state_process() in tcp_input.c
> 
> Before:  If an ACK/RST packet is received, then tcp_rcv_state_process() 
> would return 1 because of the ACK.  Then (following the function calls 
> in tcp_ipv4.c and tcp_minisocks.c), tcp_v4_send_reset() is called--but 
> since there is a RST in the packet it just returns.  After this, the 
> kfree_skb() is called.  The same goes in tcp_ipv6.c as well.
> 
> But if the order of the ACK and RST checking is reversed, __kfree_skb() 
> is called in tcp_rcv_state_process() because of the RST and the function 
> returns 0, which skips that other useless stuff.
> 
> This is the order specified on page 65 of RFC 793 anyway.
> 
> Signed-off-by: Kris Katterjohn <katterjohn@gmail.com>

This code has been like this for I don't know how many years,
the end result is the same both before and after your patch,
and the added expense of the existing code is frankly trivial.

I really don't want to apply this, it doesn't buy us anything,
sorry.
