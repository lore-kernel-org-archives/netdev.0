From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iptables very slow after commit
 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sat, 11 Apr 2009 08:07:39 -0700
Message-ID: <20090411080739.4cb77370@nehalam>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com>
	<20090410095246.4fdccb56@s6510>
	<20090410.182507.140306636.davem@davemloft.net>
	<alpine.LFD.2.00.0904101828490.4583@localhost.localdomain>
	<20090411041533.GB6822@linux.vnet.ibm.com>
	<alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, kaber@trash.net,
	r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43433 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752640AbZDKPHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2009 11:07:53 -0400
In-Reply-To: <alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 11 Apr 2009 07:14:50 +0200 (CEST)
Jan Engelhardt <jengelh@medozas.de> wrote:

> 
> On Saturday 2009-04-11 06:15, Paul E. McKenney wrote:
> >On Fri, Apr 10, 2009 at 06:39:18PM -0700, Linus Torvalds wrote:
> >>An unhappy user reported:
> >>>>> Adding 200 records in iptables took 6.0sec in 2.6.30-rc1 compared to 
> >>>>> 0.2sec in 2.6.29. I've bisected down this commit.
> >>>>> 784544739a25c30637397ace5489eeb6e15d7d49
> >> 
> >> I wonder if we should bring in the RCU people too, for them to tell you 
> >> that the networking people are beign silly, and should not synchronize 
> >> with the very heavy-handed
> >> 
> >> 	synchronize_net()
> >> 
> >> but instead of doing synchronization (which is probably why adding a few 
> >> hundred rules then takes several seconds - each synchronizes and that 
> >> takes a timer tick or so), add the rules to be free'd on some rcu-freeing 
> >> list for later freeing.
> 
> iptables works in whole tables. Userspace submits a table, checkentry is 
> called for all rules in the new table, things are swapped, then destroy 
> is called for all rules in the old table. By that logic (which existed
> since dawn I think), only the swap operation needs to be locked.
> 

Part of the overhead is the API choice to take counter values from user
space during the replace.  If the rule replacement just always started with
zero counters it could be done with less overhead.
