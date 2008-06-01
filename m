From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] net/core/sock.c remove extra wakeup
Date: Sun, 01 Jun 2008 23:03:41 +0200
Message-ID: <87prr027gy.fsf@basil.nowhere.org>
References: <483F99090200005A00037FFE@lucius.provo.novell.com>
	<483F990C0200005A00038001@lucius.provo.novell.com>
	<483FDE61020000C7000389F6@lucius.provo.novell.com>
	<483FDE61020000C7000389F6@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Gregory Haskins" <GHaskins@novell.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: "Patrick Mullaney" <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:41433 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbYFAVFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 17:05:38 -0400
In-Reply-To: <483FDE61020000C7000389F6@lucius.provo.novell.com> (Patrick Mullaney's message of "Fri, 30 May 2008 11:00:49 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Patrick Mullaney" <pmullaney@novell.com> writes:
>
> Would a better approach be?
>
> 1) clear the bit when the waiter returns(bottom of sock_wait_for_wmem)
> 2) add a new wait-queue to the socket to separate the writers
> 3) another idea?

A large reason this is tricky is because it is essentially lockless. So
alternative would be:

4) you add a spinlock which is always taken around the various condition
checks and bit manipulation. Not 100% sure if it would be bad to 
general SMP scalability (you would need to ensure that the bouncing
lock cache line isn't a performance problem), but at least it would 
be much safer and makes it much easier to verify your change is correct.

Actually the wait queue already has such a lock, so it might not be
that expensive if you switch the wait queue to a lockless version.

-Andi

