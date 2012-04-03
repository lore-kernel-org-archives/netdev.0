From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: allow splice() to build full TSO packets
Date: Tue, 03 Apr 2012 18:50:55 -0400 (EDT)
Message-ID: <20120403.185055.1492466245744649655.davem@davemloft.net>
References: <20120403.172126.672236532461758456.davem@davemloft.net>
	<1333488689.18626.331.camel@edumazet-glaptop>
	<20120403.173614.962252876842659412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, hkchu@google.com, maze@google.com,
	maheshb@google.com, ilpo.jarvinen@helsinki.fi, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab2DCWvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:51:08 -0400
In-Reply-To: <20120403.173614.962252876842659412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 03 Apr 2012 17:36:14 -0400 (EDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 03 Apr 2012 23:31:29 +0200
> 
>> The code in tcp_sendmsg() and do_tcp_sendpages() is similar (actually
>> probably copy/pasted) but the thing is tcp_sendmsg() is called once per
>> sendmsg() call (and the push logic is OK at the end of it), while a
>> single splice() system call can call do_tcp_sendpages() 16 times (or
>> even more if pipe buffer was extended by fcntl(F_SETPIPE_SZ))
> 
> Ok, so this means that in essence the tcp_mark_push should also only
> be done in the final sendpage call.
> 
> And since I'm wholly convinced that the URG stuff is a complete
> "don't care" for this path, I'm convinced your patch is the right
> thing to do.
> 
> Applied to 'net' and queued up for -stable, thanks Eric.

Eric, sorry to be a pain, but to clear my conscience can you tell me
if the sendfile() path do the right thing with your change too?

I'm concerned about returning back into userspace without at least
one tcp_push() at the end.
