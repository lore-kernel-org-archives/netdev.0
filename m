From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/802/mrp: fix possible race condition when calling
 mrp_pdu_queue()
Date: Fri, 12 Apr 2013 15:11:25 -0400 (EDT)
Message-ID: <20130412.151125.1267276967257090325.davem@davemloft.net>
References: <1365724035-30220-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com, eric.dumazet@gmail.com
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab3DLTL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 15:11:26 -0400
In-Reply-To: <1365724035-30220-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Thu, 11 Apr 2013 19:47:15 -0400

> (Adapted from a very similar change to net/802/garp.c by Cong Wang.)
> 
> mrp_pdu_queue() should ways be called with the applicant spin lock.
> mrp_uninit_applicant() only holds the rtnl lock which is not enough;
> a race is possible because mrp_rcv() is called in BH context:
> 
> 	mrp_rcv()
> 	  |->mrp_pdu_parse_msg()
> 	    |->mrp_pdu_parse_vecattr()
> 	      |->mrp_pdu_parse_vecattr_event()
> 	        |-> mrp_attr_event()
> 	          |-> mrp_pdu_append_vecattr_event()
> 	            |-> mrp_pdu_queue()
> 
> Cc: Cong Wang <amwang@redhat.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Applied and queued up for -stable, thanks.
