From: David Miller <davem@davemloft.net>
Subject: Re: initial congestion window for connections in the listen queue
Date: Mon, 13 Apr 2009 14:26:53 -0700 (PDT)
Message-ID: <20090413.142653.267913010.davem@davemloft.net>
References: <200904132346.15783.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48834
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751522AbZDMV1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 17:27:04 -0400
In-Reply-To: <200904132346.15783.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Mon, 13 Apr 2009 23:46:15 +0300

> 
> A question for the TCP wizards:
> 
>>struct sock *tcp_create_openreq_child(struct sock *sk, 
>>        struct request_sock >*req, struct sk_buff *skb)
>>{
>>...
>>         /* So many TCP implementations out there (incorrectly) count the
>>          * initial SYN frame in their delayed-ACK and congestion control
>>          * algorithms that we must have the following bandaid to talk 
>>          * efficiently to them.  -DaveM
>>          */
>>          newtp->snd_cwnd = 2;
> 
> Shouldn't the same logic from tcp_init_cwnd() be used here?
> 
>>From my traces, this seems to prevent TSO from helping short lived 
> connections.

On any standard ethernet MTU or larger, you should be getting
an initial CWND of 3 or 4 because of the logic in tcp_init_cwnd().

Don't just guesstimate what initial ->snd_cwnd value the
kernel is using by looking casually at tcpdump traces.  Add
some kernel debugging printk's and find out for sure.
