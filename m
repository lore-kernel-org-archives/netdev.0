From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: Fix deadlock between call creation and
 sendmsg/recvmsg
Date: Wed, 01 Mar 2017 12:51:26 -0500 (EST)
Message-ID: <20170301.125126.437185722854151936.davem@davemloft.net>
References: <148821018671.8207.5142446588523098523.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148821018671.8207.5142446588523098523.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Mon, 27 Feb 2017 15:43:06 +0000

> All the routines by which rxrpc is accessed from the outside are serialised
> by means of the socket lock (sendmsg, recvmsg, bind,
> rxrpc_kernel_begin_call(), ...) and this presents a problem:
 ...
> Fix this by:
 ...
> This patch has the nice bonus that calls on the same socket are now to some
> extent parallelisable.
> 
> 
> Note that we might want to move rxrpc_service_prealloc() calls out from the
> socket lock and give it its own lock, so that we don't hang progress in
> other calls because we're waiting for the allocator.
> 
> We probably also want to avoid calling rxrpc_notify_socket() from within
> the socket lock (rxrpc_accept_call()).
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> Tested-by: Marc Dionne <marc.c.dionne@auristor.com>

Applied, thanks David.
