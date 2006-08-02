From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [patch] RFC: matching interface groups
Date: Wed, 02 Aug 2006 09:04:29 +0200
Message-ID: <1154502269.6241.11.camel@bzorp.balabit>
References: <1154452209.6395.77.camel@bzorp.balabit>
	 <20060801184655.GA7452@linuxace.com>
	 <20060801191805.GA28649@zion.homelinux.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Phil Oester <kernel@linuxace.com>,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from balabit.hu ([82.141.167.23]:47529 "EHLO balabit.hu")
	by vger.kernel.org with ESMTP id S1751282AbWHBHEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 03:04:32 -0400
To: Sven Schuster <schuster.sven@gmx.de>
In-Reply-To: <20060801191805.GA28649@zion.homelinux.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-01 at 21:18 +0200, Sven Schuster wrote:
> Hi Phil,
> 
> On Tue, Aug 01, 2006 at 11:46:55AM -0700, Phil Oester told us:
> > Since in this scenario userspace is able to determine ppp vs pptp, 
> > could you not also do something like have an inbound_ppp and inbound_pptp
> > chain, then jump to the appropriate chain depending on type?  If you
> > need per-interface rules, then create an inbound_pppX chain, populate
> > it with rules, then jump to that chain if -i pppX.  In ip-down, just
> > delete the chain as well as the jump.
> 
> if I understood Balazs correctly, one of the things he wanted to
> avoid is addition/deletion of iptables rules on every pppX interface
> up/down 

Exactly.

> as this would require the complete chain (say, INPUT or
> OUTPUT) to be "downloaded" to userspace, modified and then again
> "uploaded" to the kernel. At least until iptables redesign to
> allow replacement/insertion/deletion of single rules is completed
> which if started at all will take quite some more time :-)

Iptables operates on a per-table basis, so it is not only the INPUT or
OUTPUT chain that needs to be down and uploaded, but the whole filter
table.

And in addition, in my humble opinion the iptables ruleset should be up
to the user to maintain, once some kind of automatism starts to
add/remove rules on the fly, it becomes more difficult to do other
changes to add independent rules to the table. For example the user
needs to save the current ruleset using iptables-save, then modify the
resulting file, and then load it again. If the ruleset is generated as
it happens with a lot of tools, this might not be so easy.

-- 
Bazsi

