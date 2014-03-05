From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: Don't call driver methods from interrupt
 context.
Date: Tue, 04 Mar 2014 19:26:16 -0500 (EST)
Message-ID: <20140304.192616.918758436987378525.davem@davemloft.net>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<87d2i17bq8.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241AbaCEA0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 19:26:18 -0500
In-Reply-To: <87d2i17bq8.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 04 Mar 2014 16:03:43 -0800

> So I would like some clear guidance.  Will you accept patches to make
> it safe to call the napi poll routines from hard irq context, or should
> we simply defer messages prented with netconsole in hard irq context
> into another context where we can run the napi code?
> 
> If there is not a clear way to fix the problems that crop up we should
> just delete all of the netpoll code altogether, as it seems deadly in
> it's current form.

Clearly to make netconsole most useful we should synchronously emit
log messages.

Because what if the system hangs right after this event, but before
we get back to a "safe" context.

That's one bug that will be a billion times harder to diagnose if
we defer.
