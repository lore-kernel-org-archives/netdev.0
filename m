From: Joe Cao <caoco2002@yahoo.com>
Subject: bug and question in tcp stack
Date: Fri, 12 Feb 2010 15:22:16 -0800 (PST)
Message-ID: <157135.69931.qm@web63405.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web63405.mail.re1.yahoo.com ([69.147.97.45]:23357 "HELO
	web63405.mail.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753264Ab0BLX26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 18:28:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I think it is an obvious bug both in the old and latest kernel:

In function net/ipv4/tcp_output.c, tcp_retransmit_skb() returns a NEGTIVE value on failures.  But in net/ipv4/tcp_timer.c, in function tcp_retransmit_timer(), the line

if (tcp_retransmit_skb(sk, tcp_write_queue_head(sk)) > 0) {

checks the return value as a positive number, which will never be true.  On failures from tcp_retransmit_skb(), the code will follow the wrong path.

My second question is regarding the function tcp_retransmit_skb().  The first check in the function is copied here:

 	/* Do not sent more than we queued. 1/4 is reserved for possible
	 * copying overhead: fragmentation, tunneling, mangling etc.
	 */
	if (atomic_read(&sk->sk_wmem_alloc) >
	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
		return -EAGAIN;


My question is if that turns out to be true, which I saw happend, how could the stack get out of the state?  Because all TCP retransmission may fail, no buffer will be released.  The connection is virtually dead.  Is that true?

Thanks,
Joe


      
