From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/7] IPv4/IPv6 unregistration  deadlock fixes
Date: Wed, 13 May 2009 19:53:40 -0700
Message-ID: <m13ab8s8cr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51478 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759948AbZENCxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 22:53:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A while ago it was noticed that unregistering network devices could cause
deadlocks if virtual files that take the rtnl_lock were accessed at the
wrong time.

After looking at the different possibilities the only way to solve it
cleanly without some kind of busy loop appears to be reducing the scope
of the rtnl lock.

I have not tackled the hard fix yet but I have tested our current work
around and it does not succeed in restarting the system call and
instead leaks -ERESTARNOSYS to userspace, because we do not have a
signal pending.

Further the current work around misses several interesting places
in the network stack where the deadlock can occur.

I have addressed the problems by making a common helper function
and patching all of the places I could find that had this problem.

Eric








