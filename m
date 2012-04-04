From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: allow splice() to build full TSO packets
Date: Wed, 04 Apr 2012 02:20:06 -0400 (EDT)
Message-ID: <20120404.022006.438740898640436561.davem@davemloft.net>
References: <20120403.173614.962252876842659412.davem@davemloft.net>
	<20120403.185055.1492466245744649655.davem@davemloft.net>
	<1333520128.18626.382.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, hkchu@google.com, maze@google.com,
	maheshb@google.com, ilpo.jarvinen@helsinki.fi, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594Ab2DDGUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 02:20:20 -0400
In-Reply-To: <1333520128.18626.382.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Apr 2012 08:15:28 +0200

> On Tue, 2012-04-03 at 18:50 -0400, David Miller wrote:
> 
>> Eric, sorry to be a pain, but to clear my conscience can you tell me
>> if the sendfile() path do the right thing with your change too?
>> 
>> I'm concerned about returning back into userspace without at least
>> one tcp_push() at the end.
> 
> Absolutely, this patch also handles the sendfile() path.
> 
> do_sendfile() ->
>  do_splice_direct() ->
>   splice_direct_to_actor() -> 
>    ...
>     splice_from_pipe() ->
>      splice_from_pipe_feed() ->
>       pipe_to_sendpage()  more = (sd->flags & SPLICE_F_MORE) || sd->len < sd->total_len
>        sock_sendpage() if (more) flags |= MSG_MORE;
>         kernel_sendpage()
>          inet_sendpage()
>           tcp_sendpage()
> 
> So the push is perfomed at the end (last page doesnt have MSG_MORE flag)

Perfect, thanks for double checking.
