From: Chuck Ebbert <cebbert@redhat.com>
Subject: Oops in nf_nat_core.c:find_appropriate_src(), kernel 2.6.25.4
Date: Sat, 07 Jun 2008 10:43:01 -0400
Message-ID: <484A9E75.8000601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37729 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756201AbYFGOor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jun 2008 10:44:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported at https://bugzilla.redhat.com/show_bug.cgi?id=449315

In find_appropriate_src():

        hlist_for_each_entry_rcu(nat, n, &bysource[h], bysource) {
                ct = nat->ct;
                if (same_src(ct, tuple)) {

Dereference of ct in same_src() causes the oops. This only seems to
happen on heavily loaded firewall machines. Kernel 2.6.24.7 works.

The reporter identifies commit 4d354c5782dc352cec187845d17eedc2c2bfcf67
("[NETFILTER]: nf_nat: use RCU for bysource hash") as a possible cause
of the problem.
