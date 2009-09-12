From: Robert Varga <nite@hq.alert.sk>
Subject: tcp_put_md5sig_pool() from tcp_twsk_destructor()?
Date: Sat, 12 Sep 2009 03:04:01 +0200
Message-ID: <20090912010401.GA28539@hq.alert.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq.alert.sk ([195.95.205.245]:58396 "EHLO hq.alert.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353AbZILBNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 21:13:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have recently came across a preemption imbalance detected by:

<4>huh, entered ffffffff80644630 with preempt_count 00000102, exited with 00000101?
<0>------------[ cut here ]------------
<2>kernel BUG at /usr/src/linux/kernel/timer.c:664!
<0>invalid opcode: 0000 [1] PREEMPT SMP

with ffffffff80644630 being inet_twdr_hangman().

This appeared after I enabled CONFIG_TCP_MD5SIG and played with it a
bit, so I looked at what might have caused it.

One thing that struck me as strange is tcp_twsk_destructor(), as that
calls tcp_put_md5sig_pool() -- which entails a put_cpu(), which does not
make sense to me -- and would explain the imbalance.

Shouldn't tcp_twsk_destructor() be calling tcp_free_md5sig_pool()
instead?

Please CC: me, as I am not subscribed to the list.

-- 
Bye,
Robert Varga

Reality continues to ruin my life. -- Calvin
