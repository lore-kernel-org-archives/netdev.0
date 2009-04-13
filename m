From: Octavian Purdila <opurdila@ixiacom.com>
Subject: initial congestion window for connections in the listen queue
Date: Mon, 13 Apr 2009 23:46:15 +0300
Message-ID: <200904132346.15783.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:22213 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750942AbZDMVCW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 17:02:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A question for the TCP wizards:

>struct sock *tcp_create_openreq_child(struct sock *sk, 
>        struct request_sock >*req, struct sk_buff *skb)
>{
>...
>         /* So many TCP implementations out there (incorrectly) count the
>          * initial SYN frame in their delayed-ACK and congestion control
>          * algorithms that we must have the following bandaid to talk 
>          * efficiently to them.  -DaveM
>          */
>          newtp->snd_cwnd = 2;

Shouldn't the same logic from tcp_init_cwnd() be used here?

>From my traces, this seems to prevent TSO from helping short lived 
connections.

Thanks,
tavi

