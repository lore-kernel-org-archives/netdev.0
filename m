From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Date: Fri, 19 Jun 2015 18:14:40 -0400
Message-ID: <20150619181440.22f54e6a@gandalf.local.home>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
	<CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	<20150618154914.57424225@gandalf.local.home>
	<20150618185051.2b2828c3@tlielax.poochiereds.net>
	<20150618210843.4b09c31c@grimm.local.home>
	<20150618213702.33f64b20@synchrony.poochiereds.net>
	<20150619122553.43d2d86c@gandalf.local.home>
	<20150619131759.7b38d9de@gandalf.local.home>
	<CAHQdGtRCYoeToxyDHjnd+6f40J8SrScmQKKOW5O8AzJo3NefAA@mail.gmail.com>
	<20150619155226.7c5d6637@synchrony.poochiereds.net>
	<1434745818.8838.1.camel@primarydata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Bruce James Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434745818.8838.1.camel-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Jun 2015 16:30:18 -0400
Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> wrote:

> Steven, how about something like the following patch?
> 

OK, the box I'm running this on is using v4.0.5, can you make a patch
based on that, as whatever you make needs to go to stable as well.

distcc[31554] ERROR: compile /home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c on fedora/8 failed
distcc[31554] (dcc_build_somewhere) Warning: remote compilation of '/home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c' failed, retrying locally
distcc[31554] Warning: failed to distribute /home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c to fedora/8, running locally instead
/home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c: In function 'xs_tcp_shutdown':
/home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c:643:3: error: implicit declaration of function 'xs_reset_transport' [-Werror=implicit-function-declaration]
/home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c: At top level:
/home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c:825:13: warning: conflicting types for 'xs_reset_transport' [enabled by default]
/home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c:825:13: error: static declaration of 'xs_reset_transport' follows non-static declaration
/home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c:643:3: note: previous implicit declaration of 'xs_reset_transport' was here
cc1: some warnings being treated as errors
distcc[31554] ERROR: compile /home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c on localhost failed
/home/rostedt/work/git/nobackup/linux-build.git/scripts/Makefile.build:258: recipe for target 'net/sunrpc/xprtsock.o' failed
make[3]: *** [net/sunrpc/xprtsock.o] Error 1

-- Steve

> 8<-----------------------------------------------------------------
> >From 9a0bcfdbdbc793eae1ed6d901a6396b6c66f9513 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
> Date: Fri, 19 Jun 2015 16:17:57 -0400
> Subject: [PATCH] SUNRPC: Ensure we release the TCP socket once it has been
>  closed
> 
> This fixes a regression introduced by commit caf4ccd4e88cf2 ("SUNRPC:
> Make xs_tcp_close() do a socket shutdown rather than a sock_release").
> Prior to that commit, the autoclose feature would ensure that an
> idle connection would result in the socket being both disconnected and
> released, whereas now only gets disconnected.
> 
> While the current behaviour is harmless, it does leave the port bound
> until either RPC traffic resumes or the RPC client is shut down.
> 
> Reported-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
> Signed-off-by: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
> ---
>  net/sunrpc/xprt.c     | 2 +-
>  net/sunrpc/xprtsock.c | 8 ++++++--
>  2 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 3ca31f20b97c..ab5dd621ae0c 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -611,8 +611,8 @@ static void xprt_autoclose(struct work_struct *work)
>  	struct rpc_xprt *xprt =
>  		container_of(work, struct rpc_xprt, task_cleanup);
>  
> -	xprt->ops->close(xprt);
>  	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> +	xprt->ops->close(xprt);
>  	xprt_release_write(xprt, NULL);
>  }
>  
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index fda8ec8c74c0..75dcdadf0269 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -634,10 +634,13 @@ static void xs_tcp_shutdown(struct rpc_xprt *xprt)
>  	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
>  	struct socket *sock = transport->sock;
>  
> -	if (sock != NULL) {
> +	if (sock == NULL)
> +		return;
> +	if (xprt_connected(xprt)) {
>  		kernel_sock_shutdown(sock, SHUT_RDWR);
>  		trace_rpc_socket_shutdown(xprt, sock);
> -	}
> +	} else
> +		xs_reset_transport(transport);
>  }
>  
>  /**
> @@ -786,6 +789,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xprt)
>  	xs_sock_reset_connection_flags(xprt);
>  	/* Mark transport as closed and wake up all pending tasks */
>  	xprt_disconnect_done(xprt);
> +	xprt_force_disconnect(xprt);
>  }
>  
>  /**

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
