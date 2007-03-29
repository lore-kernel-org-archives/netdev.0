From: Steven Whitehouse <swhiteho@redhat.com>
Subject: DECnet routing rule resolution
Date: Thu, 29 Mar 2007 17:24:10 +0100
Message-ID: <1175185450.1636.124.camel@quoit.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick Caulfield <pcaulfie@redhat.com>
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932953AbXC2QSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 12:18:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

One of the effects of the recent tidy up of the DECnet routing rules
code is that we are no longer able to see the difference between reading
a rule of type FR_ACT_UNREACHABLE returning -ENETUNREACH and simply
running out of rules to look at, which also returns the same thing.

The DECnet code used to return -ESRCH if it ran out of rules in which
case the test in dn_route.c (which resulted in DECnet falling back to
endnode routing in the -ESRCH case) no longer works.

So there seems to be several options to try and solve this: one is to
change the error return for running out of rules in
fib_rules.c:fib_rules_lookup() to something else (but then that has a
knock on effect in the ipv4 code). Another is to add the "not found"
error return as a parameter in the struct fib_rules_ops so that both
protocols can have their preferred error return. Both solutions seem a
bit messy, so I thought I'd ask for some guidance on this before writing
a patch,


Steve.


