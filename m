From: Martin Lucina <mato@kotelna.sk>
Subject: Workqueues vs. kernel threads for processing asynchronous socket
	events
Date: Fri, 10 Dec 2010 16:27:54 +0100
Message-ID: <20101210152754.GC28580@dezo.moloch.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Sustrik <sustrik@250bpm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:47782 "EHLO mail.moloch.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750725Ab0LJP16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 10:27:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to find the best mechanism to process events from kernel space
sockets in an asynchronous manner. The work in progress code I have at the
moment tries to at least call kernel_accept() on a bound TCP socket when it
gets called by the underlying sk->sk_data_ready callback.

The current approach I have is to use a workqueue and try to schedule work
inside the callback, but this has the kernel complaining about "scheduling
while atomic", so it doesn't look like it's the right approach? Am I
allowed to call schedule_work() from the context of a sk->sk_data_ready
callback or not?

Sunrpc/knfsd appears to use a different approach where
svc_tcp_listen_data_ready() sets the appropriate state and then calls
wake_up_interruptible_all(sk_sleep(sk)) -- it's not clear who this is
waking up, the nfsd kernel thread or someone else?

Any advice on what is the best future-proof approach to use for this kind
of thing in a new project?

-mato
