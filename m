From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 802: fix a possible race condition
Date: Sun, 24 Mar 2013 17:24:03 -0400 (EDT)
Message-ID: <20130324.172403.776354963637295731.davem@davemloft.net>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
	<1364015648-4195-1-git-send-email-amwang@redhat.com>
	<1364015648-4195-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.ward@ll.mit.edu, jorge@dti2.net
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808Ab3CXVYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:24:05 -0400
In-Reply-To: <1364015648-4195-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sat, 23 Mar 2013 13:14:08 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> garp_pdu_queue() should ways be called with this spin lock.
> garp_uninit_applicant() only holds rtnl lock which is not
> enough here.
> 
> Found by code inspection.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: David Ward <david.ward@ll.mit.edu>
> Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Under what conditions can entries be removed or added to
these RB-trees without the RTNL being held?

If such events cannot happen, then no locking is needed.

Even if your change is correct and necessary, the answer to my
needs to be added to your commit message.

Thanks.
