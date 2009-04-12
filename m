From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: iptables very slow after commit 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sun, 12 Apr 2009 11:23:12 +0400
Message-ID: <20090412072312.GA24580@ioremap.net>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com> <20090410095246.4fdccb56@s6510> <20090410.182507.140306636.davem@davemloft.net> <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain> <20090411041533.GB6822@linux.vnet.ibm.com> <alpine.LFD.2.00.0904111150380.4583@localhost.localdomain> <20090412003445.GK6822@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Lai Jiangshan <laijs@cn.fujitsu.com>, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090412003445.GK6822@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Sat, Apr 11, 2009 at 05:34:45PM -0700, Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> The issue at this point seems to be the need to get accurate snapshots
> of various counters -- there are a number of Linux networking users who
> need to account for every byte flowing through their systems.  However,

If we add or change the rule we can not know if iptables' return to
userspace does mean that rule started to act. There may be other queues
already filled with the packets which could match the new rule (like
receiving socket buffer). So effectively we want it to take effect very
soon. What if there will be a timer which will synchronize RCU-added states,
so if we update single rule - it will take effect in a second, and if we
update bunch of them - during the delay second we pretty much can load
them all.

-- 
	Evgeniy Polyakov
