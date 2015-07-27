From: Phil Sutter <phil@nwl.cc>
Subject: ip6t_SYNPROXY crashes kernel
Date: Tue, 28 Jul 2015 00:27:16 +0200
Message-ID: <20150727222716.GG20951@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:56906 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781AbbG0W1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 18:27:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When synproxy_send_server_ack() calls synproxy_send_tcp(), it passes
NULL as third parameter (struct nf_conntrack *nfct). And the first thing
synproxy_send_tcp() does, is dereference it:

| struct net *net = nf_ct_net((struct nf_conn *)nfct);

I could not find a commit leading to this breakage in the commit log,
which makes me doubt ip6t_SYNPROXY has ever worked at all.

If you need one, I have a reproducer at hand. (Though I would want to
strip it down a bit first.) Just let me know.

Cheers, Phil
