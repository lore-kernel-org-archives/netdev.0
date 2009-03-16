From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] pkt_sched: Change misleading code in class delete.
Date: Sun, 15 Mar 2009 20:00:32 -0700 (PDT)
Message-ID: <20090315.200032.194674635.davem@davemloft.net>
References: <20090314144528.GA24995@ami.dom.local>
	<20090315123511.GA2713@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m0sia@m0sia.ru, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35149
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752847AbZCPDAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 23:00:45 -0400
In-Reply-To: <20090315123511.GA2713@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 15 Mar 2009 13:35:11 +0100

> While looking for a possible reason of bugzilla report on HTB oops:
> http://bugzilla.kernel.org/show_bug.cgi?id=12858
> I found the code in htb_delete calling htb_destroy_class on zero
> refcount is very misleading: it can suggest this is a common path, and
> destroy is called under sch_tree_lock. Actually, this can never happen
> like this because before deletion cops->get() is done, and after
> delete a class is still used by tclass_notify. The class destroy is
> always called from cops->put(), so without sch_tree_lock.
> 
> This doesn't mean much now (since 2.6.27) because all vulnerable calls
> were moved from htb_destroy_class to htb_delete, but there was a bug
> in older kernels. The same change is done for other classful scheds,
> which, it seems, didn't have similar locking problems here.
> 
> Reported-by: m0sia <m0sia@m0sia.ru>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks a lot Jarek.
