From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 802: fix a possible race condition
Date: Sun, 07 Apr 2013 17:04:33 -0400 (EDT)
Message-ID: <20130407.170433.1137459032889983595.davem@davemloft.net>
References: <1364975560-6812-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	david.ward@ll.mit.edu, jorge@dti2.net
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934312Ab3DGVEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 17:04:35 -0400
In-Reply-To: <1364975560-6812-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed,  3 Apr 2013 15:52:40 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> (Resend with a better changelog)
> 
> garp_pdu_queue() should ways be called with this spin lock.
> garp_uninit_applicant() only holds rtnl lock which is not
> enough here.  A possible race can happen as garp_pdu_rcv()
> is called in BH context:
> 
> 	garp_pdu_rcv()
> 	  |->garp_pdu_parse_msg()
> 	    |->garp_pdu_parse_attr()
> 	      |-> garp_gid_event()
> 
> Found by code inspection.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: David Ward <david.ward@ll.mit.edu>
> Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
