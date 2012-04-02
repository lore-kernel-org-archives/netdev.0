From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 00/51] Get rid of NLA_PUT*()
Date: Sun,  1 Apr 2012 22:57:50 -0400
Message-ID: <1333335521-1348-1-git-send-email-davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753850Ab2DBC6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:58:53 -0400
Received: from davemloft.net (cpe-66-108-118-54.nyc.res.rr.com [66.108.118.54])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q322whmk022214
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 1 Apr 2012 19:58:52 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series gets rid of all uses of NLA_PUT*() and then kills
the definitions of those macros from netlink.h

For the most part, I've tried to do just a straight conversion of:

	NLA_PUT*(...);

to

	if (nla_put*(...))
		goto nla_put_failure;

However in several cases I've tried to make things look more
reasonable, for example:

	if (val)
		NLA_PUT*();

becomes:

	if (val &&
	    nla_put*())
		goto nla_put_failure;

multiple consequetive puts get combined into one if() statement, like:

	if (nla_put_u32(...) ||
	    nla_put_string(...))
		goto nla_put_failure;

One thing I have not done is try to get rid of the nla_put_failure
label, even in the really simply cases.  That's another cleanup
altogether, but I will not that some cases can be reduced down to
nothing more than:

	return nla_put*(...);

Throughout the series, as new (lowercase) nla_put*() intefaces were
needed, I added them, right before the first commit to make use of
them.

Examples are nla_put_be*(), nlaa_put_net*(), and nla_put_le*().

These are the first commits that will show up in net-next when I open
it up.
