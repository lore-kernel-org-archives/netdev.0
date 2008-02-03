From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Unbreak sky2 on 88E8039 with current git
Date: Sun, 3 Feb 2008 10:08:47 -0800
Message-ID: <20080203100847.3022883e@extreme>
References: <20080202105243.GA14581@vana.vc.cvut.cz>
	<20080202120203.5387d1cb@extreme>
	<47A51168.5040301@vandrovec.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Petr Vandrovec <petr@vandrovec.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33764 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751106AbYBCSJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 13:09:30 -0500
In-Reply-To: <47A51168.5040301@vandrovec.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 02 Feb 2008 16:57:12 -0800
Petr Vandrovec <petr@vandrovec.name> wrote:

> Stephen Hemminger wrote:
> > On Sat, 2 Feb 2008 11:52:43 +0100
> > Petr Vandrovec <petr@vandrovec.name> wrote:
> > 
> >> Hello,
> >>   since I synced my tree to Linus's one two days ago, sky2's packet receiption
> >> dies almost instantly.  Device still transmits packets, but no receive.  
> >> Fortunately fix is simple, unfortunately I do not know why fix works...
> >>
> >> Commit f03b865491c2f30f2a4d77cdafc69c978ceb38a0 (sky2: align IP header on Rx
> >> if possible) stopped aligning receive buffers on devices which do not need
> >> HANG_CHECK.  Unfortunately there is at least one device (mine, Yukon FE, rev 3)
> >> which is not happy if receive buffer is not aligned.  I have no idea which
> >> other chips/revisions are affected as well.
> >>
> >> Without patch 'ping -f -b 192.168.101.255' RX count stops incrementing in less
> >> than 50 packets.  With patch in place it can run like before, for hours...
> >> Box is an AMD rev F processor, with nVidia's MCP61 chipset.
> >> 							Petr
> > 
> > I don't have a Yukon FE, but I believe that the Yukon FE does have a ram
> > buffer, so you HANG_CHECK should be enabled for that device. You can check
> > by running:
> > 	ethtool -d eth0 | grep 'Ram Buffer'
> > With ram buffer (like XL, EC)
> > 	
> > # ethtool -d eth0 | grep 'Ram Buffer'
> > Ram Buffer                   0x18
> > 
> > No ram buffer (like EC-U, FE+, ...)
> > # ethtool -d eth0 | grep 'Ram Buffer'
> > Ram Buffer                   0x00
> 
> Some small one (if it is size):
> 
> gwy:~# ethtool -d eth0 | grep 'Ram'
> Ram Buffer                   0x01
> 
> I've never observed hang on that device, and I have it for over year. I 
> stress it sufficiently to kill EC rev 2 I have in the notebook when I 
> copy some data between these two boxes, but this FE never hung.
> 							Petr
> 

Since the ram buffer is only 4K on this chip, 2K is used for rx.
You probably could make it hang by making CPU busy and hitting it
with 2 packets whose total length is was 1K each.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
