From: Martin Lucina <mato@kotelna.sk>
Subject: Correct procedure to close an in-kernel TCP socket
Date: Wed, 6 Apr 2011 13:55:45 +0200
Message-ID: <20110406115545.GA16094@dezo.moloch.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Sustrik <sustrik@250bpm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:58358 "EHLO mail.moloch.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754958Ab1DFMGK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 08:06:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We're having some problems with code that uses in-kernel TCP sockets
created with sock_create_kern().

At the moment we are doing this when closing a socket:

	write_lock_bh(&s->sk->sk_callback_lock);
	s->sk->sk_state_change = old_sk_state_change;
	s->sk->sk_data_ready = old_sk_data_ready;
	s->sk->sk_write_space = old_sk_write_space;
	write_unlock_bh(&s->sk->sk_callback_lock);

        /* ... */
	
        sock_release(s);

We then see that at some point in the future our s->sk->sk_state_change
callback is still being called despite the code above restoring the
original values.

Is there something we're doing wrong? 

Thanks,

-mato
