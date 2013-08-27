From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH 2/3] [RFC] TCP syncookies: introduce sysctl to configure
 the MSS tables
Date: Tue, 27 Aug 2013 14:55:51 +0200
Message-ID: <20130827125551.GA1195@midget.suse.cz>
References: <520A3B4A.1050704@jakoblell.com>
 <20130815235743.GA25665@midget.suse.cz>
 <20130816000303.GB11950@midget.suse.cz>
 <20130816214057.GE5154@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, Jakob Lell <jakob@jakoblell.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40081 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164Ab3H0Mz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 08:55:56 -0400
Content-Disposition: inline
In-Reply-To: <20130816214057.GE5154@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 16, 2013 at 11:40:57PM +0200, Florian Westphal wrote:
> Jiri Bohac <jbohac@suse.cz> wrote:
> > (compile-tested only)
> > 
> > This patch introduces two new sysctls
> > 	net.ipv4.tcp_syncookies_mss_table
> > 	net.ipv6.tcp_syncookies_mss_table
> > to manipulate the TCP syncookie MSS tables
> 
> The cookie MSS table is small to begin with; trying
> to find values that fit all possible clients is a losing game.

not all servers talk to all the clients. I can imagine some may run very
specific services with very specific packet sizes. Having the MSS
values configurable can't hurt.

> I cannot think of any scenarios where 2 machines, connected
> to internet, could have different mss tables whilst _both_
> improving the default values?

The recently disclosed syncookies vulnerability has differrent
impact on differrent servers.

Some services are secure enough at application level and don't
care at all about TCP connection spoofing. These can use the
sysctl to revert back to the MSS table we have now (or anyting
that better serves their traffic).

Other services are not so secure and some MSS values can be
sacrified to mitigate the risk. With a smaller MSS table, tuning
the values for specific traffic may make even more sense.


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
