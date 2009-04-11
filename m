From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: iptables very slow after commit
 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sat, 11 Apr 2009 10:51:20 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904111049010.4583@localhost.localdomain>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com> <20090410095246.4fdccb56@s6510> <20090410.182507.140306636.davem@davemloft.net> <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain> <20090411041533.GB6822@linux.vnet.ibm.com>
 <alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Lai Jiangshan <laijs@cn.fujitsu.com>, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, kaber@trash.net,
	r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 11 Apr 2009, Jan Engelhardt wrote:
> 
> iptables works in whole tables.

Not really.

Yes, iptables as a single command works in whole tables.

USERS, on the other hand, often work in multiple iptables commands, ie 
they just add things to the tables. And in fact, I think this is the exact 
workload that Jeff complains about - doing two hundred "update table" 
commands.

> Userspace submits a table, checkentry is called for all rules in the new 
> table, things are swapped, then destroy is called for all rules in the 
> old table. By that logic (which existed since dawn I think), only the 
> swap operation needs to be locked.

The problem is, the new code makes the "wait after swap" thing happen 
after every switch. And if you do two hundred "update table" commands, you 
now take a _long_ time to update.

Sure, you could tell people to just do everything as one single table 
update, but that isn't what they do.

		Linus
