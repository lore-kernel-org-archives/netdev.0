From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] net/802/mrp: fix possible race condition when calling
 mrp_pdu_queue()
Date: Fri, 12 Apr 2013 04:18:13 -0400 (EDT)
Message-ID: <2086091165.2722334.1365754693666.JavaMail.root@redhat.com>
References: <1365724035-30220-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:49894 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3DLISQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 04:18:16 -0400
In-Reply-To: <1365724035-30220-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
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

Acked-by: Cong Wang <amwang@redhat.com>

Thanks.
