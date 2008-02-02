From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Unbreak sky2 on 88E8039 with current git
Date: Sat, 2 Feb 2008 12:02:03 -0800
Message-ID: <20080202120203.5387d1cb@extreme>
References: <20080202105243.GA14581@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Petr Vandrovec <petr@vandrovec.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40228 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753870AbYBBUCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 15:02:20 -0500
In-Reply-To: <20080202105243.GA14581@vana.vc.cvut.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2 Feb 2008 11:52:43 +0100
Petr Vandrovec <petr@vandrovec.name> wrote:

> Hello,
>   since I synced my tree to Linus's one two days ago, sky2's packet receiption
> dies almost instantly.  Device still transmits packets, but no receive.  
> Fortunately fix is simple, unfortunately I do not know why fix works...
> 
> Commit f03b865491c2f30f2a4d77cdafc69c978ceb38a0 (sky2: align IP header on Rx
> if possible) stopped aligning receive buffers on devices which do not need
> HANG_CHECK.  Unfortunately there is at least one device (mine, Yukon FE, rev 3)
> which is not happy if receive buffer is not aligned.  I have no idea which
> other chips/revisions are affected as well.
> 
> Without patch 'ping -f -b 192.168.101.255' RX count stops incrementing in less
> than 50 packets.  With patch in place it can run like before, for hours...
> Box is an AMD rev F processor, with nVidia's MCP61 chipset.
> 							Petr

I don't have a Yukon FE, but I believe that the Yukon FE does have a ram
buffer, so you HANG_CHECK should be enabled for that device. You can check
by running:
	ethtool -d eth0 | grep 'Ram Buffer'
With ram buffer (like XL, EC)
	
# ethtool -d eth0 | grep 'Ram Buffer'
Ram Buffer                   0x18

No ram buffer (like EC-U, FE+, ...)
# ethtool -d eth0 | grep 'Ram Buffer'
Ram Buffer                   0x00
-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
