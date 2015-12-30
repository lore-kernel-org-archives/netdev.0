From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] unix: properly account for FDs passed over unix sockets
Date: Wed, 30 Dec 2015 13:14:47 +0000
Message-ID: <20151230131447.453c7d53@lxorguk.ukuu.org.uk>
References: <20151228141435.GA13351@1wt.eu>
	<56829D4D.4090109@stressinduktion.org>
	<20151229203527.GA13826@1wt.eu>
	<56839CC2.9080000@stressinduktion.org>
	<20151230112317.GC14049@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, socketpair@gmail.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:33453 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754724AbbL3NP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 08:15:26 -0500
In-Reply-To: <20151230112317.GC14049@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Another idea would be to add the amount of memory used to manage the fds 
> > to sock_rmem/wmem but I don't see any advantages or disadvantages.
> 
> Compared to the impact of the pending data in pipes themselves in flight,
> this would remain fairly minimal.

The true size of the memory pinned by a file handle cannot be determined
by the socket layer anyway. If the handle is for a device it may be
pinning lots of memory in the device driver. It's up to the rest of the
system to manage and contain those resource allocations correctly which a
fair bit of the code (except graphics) does properly.

The resource counting does create the reverse problem that user A running
a program written by hostile user B may find it takes all their resources,
stuffs them down an AF_UNIX socket and passes the last reference to the
socket via a setuid app somewhere where the user can't get it back.

For an end user case that's pretty irrelevant - you run hostile user B's
app then you already lost. For a service it's an interesting attack vector
but not one I can see any obvious ways to exploit because (with the
possible exception of dbus) services simply don't pass file handles down
sockets to untrusted targets.

Alan
