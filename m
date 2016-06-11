From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rxrpc: Limit the listening backlog
Date: Fri, 10 Jun 2016 18:15:19 -0700 (PDT)
Message-ID: <20160610.181519.2226683566700203919.davem@davemloft.net>
References: <146559423718.20422.5984823569057840023.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbcFKBPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 21:15:20 -0400
In-Reply-To: <146559423718.20422.5984823569057840023.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Fri, 10 Jun 2016 22:30:37 +0100

> Limit the socket incoming call backlog queue size so that a remote client
> can't pump in sufficient new calls that the server runs out of memory.  Note
> that this is partially theoretical at the moment since whilst the number of
> calls is limited, the number of packets trying to set up new calls is not.
> This will be addressed in a later patch.
> 
> If the caller of listen() specifies a backlog INT_MAX, then they get the
> current maximum; anything else greater than max_backlog or anything
> negative incurs EINVAL.
> 
> The limit on the maximum queue size can be set by:
> 
> 	echo N >/proc/sys/net/rxrpc/max_backlog
> 
> where 4<=N<=32.
> 
> Further, set the default backlog to 0, requiring listen() to be called
> before we start actually queueing new calls.  Whilst this kind of is a
> change in the UAPI, the caller can't actually *accept* new calls anyway
> unless they've first called listen() to put the socket into the LISTENING
> state - thus the aforementioned new calls would otherwise just sit there,
> eating up kernel memory.  (Note that sockets that don't have a non-zero
> service ID bound don't get incoming calls anyway.)
> 
> Given that the default backlog is now 0, make the AFS filesystem call
> kernel_listen() to set the maximum backlog for itself.
> 
> Possible improvements include:
> 
>  (1) Trimming a too-large backlog to max_backlog when listen is called.
> 
>  (2) Trimming the backlog value whenever the value is used so that changes
>      to max_backlog are applied to an open socket automatically.  Note that
>      the AFS filesystem opens one socket and keeps it open for extended
>      periods, so would miss out on changes to max_backlog.
> 
>  (3) Having a separate setting for the AFS filesystem.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
