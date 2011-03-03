From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG] VPN broken in net-next
Date: Thu, 3 Mar 2011 13:54:56 -0800
Message-ID: <20110303135456.4fca2382@nehalam>
References: <20110302.165421.258093056.davem@davemloft.net>
	<alpine.LFD.2.00.1103031414240.1677@ja.ssi.bg>
	<alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg>
	<20110303.112328.59677094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43666 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754614Ab1CCVzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 16:55:01 -0500
In-Reply-To: <20110303.112328.59677094.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Mar 2011 11:23:28 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Thu, 3 Mar 2011 15:09:22 +0200 (EET)
> 
> > On Thu, 3 Mar 2011, Julian Anastasov wrote:
> > 
> >> 	May be the problem is in inet_hash_insert(), it should
> >> hash ifa_local, not ifa_address. May be they are equal for
> > 
> > 	... and of course the new __ip_dev_find should use
> > ifa_local too.
> 
> Thanks for looking into this Julian.  I will look at the other
> cases you found later.
> 
> Stephen, is this sufficient to fix your problem?  I suspect it is
> not because fib_add_addr() adds prefixes with RTN_LOCAL to the
> local routing table too :-/
> 
> I suspect that even if we need to handle prefixes, we can still use
> the hash for optimistic lookup, and fallback to a local table FIB
> inspection if that fails.
> 
> --------------------
> ipv4: Fix __ip_dev_find() to use ifa_local instead of ifa_address.
> 
> Reported-by: Stephen Hemminger <shemminger@vyatta.com>
> Reported-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 

VPN works now with this patch on net-next.
