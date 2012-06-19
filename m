From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Prevent access to uninitialized fib_table_hash
 via /proc/net/ipv6_route
Date: Tue, 19 Jun 2012 14:13:03 -0700 (PDT)
Message-ID: <20120619.141303.61044763636341121.davem@davemloft.net>
References: <20120615105655.GA22945@hmsreliant.think-freely.org>
	<20120615.153240.1699971156820399680.davem@davemloft.net>
	<20120619113602.GG27921@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659Ab2FSVNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:13:04 -0400
In-Reply-To: <20120619113602.GG27921@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 19 Jun 2012 07:36:02 -0400

> On Fri, Jun 15, 2012 at 03:32:40PM -0700, David Miller wrote:
>> Since you're snooping around in here, you might notice that on network
>> namespace shutdown, we leak all user configured ipv6 FIB rules.
> 
> I looked into this. fib_rules_unregister() will free all rules
> belonging to the address family in that namespace.
> 
> Or were you referring to other rules?

Sorry, the leak I saw was for the fib6 tables, not the rules
themselves.

IPV4 has ip_fib_net_exit() which walks the FIB4 table hash
and releases everything.

I couldn't find the IPV6 counterpart.  All I could find was code which
explicitly liberates the ipv6 main and local tables.

There is no ipv6 code I can find which traverses fib_table_hash and
liberates the dynamically generated tables.
