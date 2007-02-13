From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic:
 swapper/0x10000100/0
Date: Tue, 13 Feb 2007 14:32:43 -0800 (PST)
Message-ID: <20070213.143243.78711492.davem@davemloft.net>
References: <20070209133802.01286bbb.akpm@linux-foundation.org>
	<20070213202905.GA26818@gospo.rdu.redhat.com>
	<200702132226.l1DMQS22009230@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, akpm@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	lpiccilli@gelre.com.br, bugme-daemon@bugzilla.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38808
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751370AbXBMWco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 17:32:44 -0500
In-Reply-To: <200702132226.l1DMQS22009230@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 13 Feb 2007 14:26:28 -0800

> 	In reference to Andy's recent patch (which first did conditional
> locking for rtnl, then later acquired rtnl for every entry into the
> timer function), I know the conditional locking isn't popular, but it
> seems to me that it's a less bad alternative than holding rtnl every
> time the bond_mii_monitor() runs (typically 10 - 50 times per second).
> Or is the rtnl lock really so cheap that this isn't an issue?  The
> overwhelming majority of cases the mii_monitor won't need to do anything
> that requires rtnl, so only holding it when needed is better.

We definitely don't want to take the RTNL that often if it can
be avoided.

Maybe if you put the RTNL acquisition deeper into the call
path, ie. down into the code that knows RTNL is needed,
perhaps it won't be so ugly.  Replace the conditions with
functions.
