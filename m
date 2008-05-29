From: David Miller <davem@davemloft.net>
Subject: Re: Question on ipmr.c locking in 2.6.25
Date: Thu, 29 May 2008 03:47:28 -0700 (PDT)
Message-ID: <20080529.034728.225207018.davem@davemloft.net>
References: <483DD0EE.1020700@candelatech.com>
	<20080528215833.GA14038@solarflare.com>
	<483DD775.2070901@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751065AbYE2Krc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 06:47:32 -0400
In-Reply-To: <483DD775.2070901@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 28 May 2008 15:06:45 -0700

> Now I wonder:  If a reader read only a small bit of the proc file,
> and then just went to sleep w/out closing or reading the rest of
> the file, would that effectively DOS a system by pinning the locks?

That's not how this works.

The in-kernel buffer used by the SEQ file infrastructure is
filled as best as possible.  Then the locks are dropped and
the copy to userspace is performed.

Since we hold locks, this also means preemption is disabled.
So there is no way for the task to go to sleep at this
time.
