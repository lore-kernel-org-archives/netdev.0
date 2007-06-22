From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BUG] Sky2 driver in 2.6.22-rc5-git1-cfs-v17
Date: Thu, 21 Jun 2007 18:57:11 -0700
Message-ID: <20070621185711.7dc9fe88@oldman>
References: <1182459092.7032.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pomac@vapor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53719 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751561AbXFVB7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 21:59:23 -0400
In-Reply-To: <1182459092.7032.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Redirected of LKML,  netdev is the proper list.

On Thu, 21 Jun 2007 22:51:32 +0200
Ian Kumlien <pomac@vapor.com> wrote:

> Hi, 
> 
> recently have started to see this in my dmesg:
> 
> NETDEV WATCHDOG: eth0: transmit timed out
> sky2 eth0: tx timeout
> sky2 eth0: transmit ring 449 .. 408 report=449 done=449
> sky2 eth0: disabling interface
> sky2 eth0: enabling interface
> sky2 eth0: ram buffer 48K
> sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control rx
> 
> I'm not using MSI since it seems to have caused problems in the past.
> 
> I run with a 9k mtu
> 
> sky2 eth0: transmit ring 18 .. 489 report=18 done=18
> ---- I assume ring max is 512 (ie 1-512) since:
> 	Ring parameters for eth0:
> 	Current hardware settings:
> 	RX:             168
> 	RX Mini:        0
> 	RX Jumbo:       0
> 	TX:             511
> 	
> 	And 489 + 41 - 18 = 512
> 
> sky2 eth0: transmit ring 197 .. 156 report=197 done=197
> sky2 eth0: transmit ring 480 .. 439 report=480 done=480
> sky2 eth0: transmit ring 413 .. 372 report=413 done=413
> sky2 eth0: transmit ring 320 .. 279 report=320 done=320
> 
> Else, they are all off by 41.
> 
> Is this a known bug?
no
> Comments? ideas?
>
which chip version. probably Yukon EC that seems to be the only one
that does gigabit with Ram buffer.

Does it work alright if you set transmit ring size smaller with ethtool?
There might be an off-by-one bug in the worst case calculations about
list element usage.
