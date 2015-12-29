From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] unix: properly account for FDs passed over unix sockets
Date: Tue, 29 Dec 2015 15:48:45 +0100
Message-ID: <56829D4D.4090109@stressinduktion.org>
References: <20151228141435.GA13351@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, socketpair@gmail.com
To: Willy Tarreau <w@1wt.eu>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56400 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752690AbbL2Ost (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 09:48:49 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 6761A2080D
	for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 09:48:49 -0500 (EST)
In-Reply-To: <20151228141435.GA13351@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.12.2015 15:14, Willy Tarreau wrote:
> It is possible for a process to allocate and accumulate far more FDs than
> the process' limit by sending them over a unix socket then closing them
> to keep the process' fd count low.
>
> This change addresses this problem by keeping track of the number of FDs
> in flight per user and preventing non-privileged processes from having
> more FDs in flight than their configured FD limit.
>
> Reported-by: socketpair@gmail.com
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Willy Tarreau <w@1wt.eu>

Thanks for the patch!

I think this does not close the DoS attack completely as we duplicate 
fds if the reader uses MSG_PEEK on the unix domain socket and thus 
clones the fd. Have I overlooked something?

Thanks,
Hannes
