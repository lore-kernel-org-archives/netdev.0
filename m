From: Jiri Bohac <jbohac@suse.cz>
Subject: accept_ra_rt_info_max_plen default value
Date: Thu, 21 Jun 2012 01:07:55 +0200
Message-ID: <20120620230755.GB4957@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Teran McKinney <sega01@gmail.com>,
	Pekka Savola <pekkas@netcore.fi>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46597 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754788Ab2FTXIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 19:08:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have been looking for the reason behind the default of
accept_ra_rt_info_max_plen being 0. No luck.

The feature has been introduced by 930d6ff2 ([IPV6]: ROUTE: Add
accept_ra_rt_info_max_plen sysctl).

The only relevant discussion I found was
http://markmail.org/message/5m34bfzhox6y5lcf
with no explanation.

I imagine that the motivation for setting
accept_ra_rt_info_max_plen to 0 would be security concerns (?).

However, RFC 4191, section "6. Security Consideration", concludes
that the new features don't increase the risks already present:

	A malicious node could send Router Advertisement messages, specifying
	a High Default Router Preference or carrying specific routes, with
	the effect of pulling traffic away from legitimate routers.  However,
	a malicious node could easily achieve this same effect in other ways.

	For example, it could fabricate Router Advertisement messages with a
	zero Router Lifetime from the other routers, causing hosts to stop
	using the other routes.  By advertising a specific prefix, this
	attack could be carried out in a less noticeable way.  However, this
	attack has no significant incremental impact on Internet
	infrastructure security.


RFC 6434 has been published since, and under 5.3. it says:

	Small Office/Home Office (SOHO) deployments supported by routers
	adhering to [RFC6204] use RFC 4191 to advertise routes to certain
	local destinations.  Consequently, nodes that will be deployed in
	SOHO environments SHOULD implement RFC 4191.


Shouldn't the default value of accept_ra_rt_info_max_plen be
re-considered to comply with RFC 6434 by default? Any reason not
to make it 128?

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
