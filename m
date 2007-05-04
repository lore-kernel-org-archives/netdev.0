From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: zero out rx_opt in tcp_disconnect()
Date: Thu, 03 May 2007 17:31:57 -0700 (PDT)
Message-ID: <20070503.173157.41635650.davem@davemloft.net>
References: <20070503185336.GA19639@rainfinity.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Aji_Srinivas@emc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58810
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767524AbXEDAbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 20:31:55 -0400
In-Reply-To: <20070503185336.GA19639@rainfinity.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aji_Srinivas@emc.com
Date: Thu, 3 May 2007 11:53:36 -0700

> When the server drops its connection, NFS client reconnects using the
> same socket after disconnecting. If the new connection's SYN,ACK
> doesn't contain the TCP timestamp option and the old connection's did,
> tp->tcp_header_len is recomputed assuming no timestamp header but
> tp->rx_opt.tstamp_ok remains set. Then tcp_build_and_update_options()
> adds in a timestamp option past the end of the allocated TCP header,
> overwriting TCP data, or when the data is in skb_shinfo(skb)->frags[],
> overwriting skb_shinfo(skb) causing a crash soon after. (The issue was
> debugged from such a crash.)
> 
> Similarly, wscale_ok and sack_ok also get set based on the SYN,ACK
> packet but not reset on disconnect, since they are zeroed out at
> initialization. The patch zeroes out the entire tp->rx_opt struct in
> tcp_disconnect() to avoid this sort of problem.
> 
> Signed-off-by: Srinivas Aji <Aji_Srinivas@emc.com>

Thanks for catching this.  It is rare to take advantage of
the connect() with AF_UNSPEC feature that allows this.

Most applications close the socket and make a new one before
connecting again.

I'll apply this fix, thanks a lot.

