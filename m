From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BUG] Sky2 driver in 2.6.22-rc5-git1-cfs-v17
Date: Thu, 21 Jun 2007 21:13:51 -0700
Message-ID: <20070621211351.6d193bed@oldman>
References: <1182459092.7032.11.camel@localhost>
	<20070621185711.7dc9fe88@oldman>
	<1182480325.7032.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pomac@vapor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47631 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820AbXFVEOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 00:14:12 -0400
In-Reply-To: <1182480325.7032.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Jun 2007 04:45:25 +0200
Ian Kumlien <pomac@vapor.com> wrote:

> On tor, 2007-06-21 at 18:57 -0700, Stephen Hemminger wrote:
> > Redirected of LKML,  netdev is the proper list.
> 
> Thanks =)
> 
> > On Thu, 21 Jun 2007 22:51:32 +0200
> > Ian Kumlien <pomac@vapor.com> wrote:
> > 
> > > Hi, 
> > > 
> > > recently have started to see this in my dmesg:
> > > 
> > > NETDEV WATCHDOG: eth0: transmit timed out
> > > sky2 eth0: tx timeout
> > > sky2 eth0: transmit ring 449 .. 408 report=449 done=449
> > > sky2 eth0: disabling interface
> > > sky2 eth0: enabling interface
> > > sky2 eth0: ram buffer 48K
> > > sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control rx
> > > 
> > > I'm not using MSI since it seems to have caused problems in the past.
> > > 
> > > I run with a 9k mtu
> > > 
> > > sky2 eth0: transmit ring 18 .. 489 report=18 done=18
> > > ---- I assume ring max is 512 (ie 1-512) since:
> > > 	Ring parameters for eth0:
> > > 	Current hardware settings:
> > > 	RX:             168
> > > 	RX Mini:        0
> > > 	RX Jumbo:       0
> > > 	TX:             511
> > > 	
> > > 	And 489 + 41 - 18 = 512
> > > 
> > > sky2 eth0: transmit ring 197 .. 156 report=197 done=197
> > > sky2 eth0: transmit ring 480 .. 439 report=480 done=480
> > > sky2 eth0: transmit ring 413 .. 372 report=413 done=413
> > > sky2 eth0: transmit ring 320 .. 279 report=320 done=320
> > > 
> > > Else, they are all off by 41.
> > > 
> > > Is this a known bug?
> > no
> 
> Damn =P
> 
> > > Comments? ideas?
> > >
> > which chip version. probably Yukon EC that seems to be the only one
> > that does gigabit with Ram buffer.
> 
> sky2 0000:02:00.0: v1.14 addr 0xdbffc000 irq 18 Yukon-EC (0xb6) rev 2
> 
> > Does it work alright if you set transmit ring size smaller with ethtool?
> > There might be an off-by-one bug in the worst case calculations about
> > list element usage.
> 
> I tried this... but not with a specific size, i think i did 480, and yes
> it timed out... any ideas on a more educated value?
> 
> -- 
> Ian Kumlien <pomac () vapor ! com> -- http://pomac.netswarm.net

Also try setting the idle_timeout module parameter to something link 10 (ms).
It will fix problems with lost interrupts.
