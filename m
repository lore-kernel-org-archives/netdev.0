From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] IPv4/IPv6 unregistration deadlock fixes
Date: Mon, 18 May 2009 22:16:37 -0700 (PDT)
Message-ID: <20090518.221637.98842683.davem@davemloft.net>
References: <m13ab8s8cr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	shemminger@vyatta.com, greearb@candelatech.com, kaber@trash.net
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33234
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753415AbZESFQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 01:16:40 -0400
In-Reply-To: <m13ab8s8cr.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 13 May 2009 19:53:40 -0700

> A while ago it was noticed that unregistering network devices could cause
> deadlocks if virtual files that take the rtnl_lock were accessed at the
> wrong time.
> 
> After looking at the different possibilities the only way to solve it
> cleanly without some kind of busy loop appears to be reducing the scope
> of the rtnl lock.
> 
> I have not tackled the hard fix yet but I have tested our current work
> around and it does not succeed in restarting the system call and
> instead leaks -ERESTARNOSYS to userspace, because we do not have a
> signal pending.
> 
> Further the current work around misses several interesting places
> in the network stack where the deadlock can occur.
> 
> I have addressed the problems by making a common helper function
> and patching all of the places I could find that had this problem.

I've added these changes to net-next-2.6, thanks.

I really can't justify sticking this into net-2.6, especially
this late in the series, sorry.
