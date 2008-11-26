From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix soft lockups/OOM issues w/ unix garbage collector
Date: Wed, 26 Nov 2008 15:32:43 -0800 (PST)
Message-ID: <20081126.153243.85669383.davem@davemloft.net>
References: <20081125231712.GA30297@ldl.fc.hp.com>
	<20081125.211913.114802735.davem@davemloft.net>
	<20081126170401.GC30297@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eteo@redhat.com
To: dannf@dannf.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60920
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752691AbYKZXcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 18:32:45 -0500
In-Reply-To: <20081126170401.GC30297@ldl.fc.hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dann frazier <dannf@dannf.org>
Date: Wed, 26 Nov 2008 10:04:02 -0700

> This is an implementation of David Miller's suggested fix in:
>   https://bugzilla.redhat.com/show_bug.cgi?id=470201
> 
> It has been updated to use wait_event() instead of
> wait_event_interruptible().
> 
> Paraphrasing the description from the above report, it makes sendmsg()
> block while UNIX garbage collection is in progress. This avoids a
> situation where child processes continue to queue new FDs over a
> AF_UNIX socket to a parent which is in the exit path and running
> garbage collection on these FDs. This contention can result in soft
> lockups and oom-killing of unrelated processes.
> 
> Signed-off-by: dann frazier <dannf@hp.com>

Applied, thanks a lot Dann.
