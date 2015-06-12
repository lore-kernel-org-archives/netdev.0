From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Date: Fri, 12 Jun 2015 08:43:42 -0700
Message-ID: <1434123822.27504.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150611234929.7b48d314@gandalf.local.home>
	 <CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	 <1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHQdGtROSzCUWaFobiEPPb2TZwduoARaHQ7viQC=XhjzyXGtrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHQdGtROSzCUWaFobiEPPb2TZwduoARaHQ7viQC=XhjzyXGtrQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-06-12 at 10:57 -0400, Trond Myklebust wrote:
> On Fri, Jun 12, 2015 at 10:40 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> > Strange, because the usual way to not have time-wait is to use SO_LINGER
> > with linger=0
> >
> > And apparently xs_tcp_finish_connecting() has this :
> >
> >                 sock_reset_flag(sk, SOCK_LINGER);
> >                 tcp_sk(sk)->linger2 = 0;
> 
> Are you sure? I thought that SO_LINGER is more about controlling how
> the socket behaves w.r.t. waiting for the TCP_CLOSE state to be
> achieved (i.e. about aborting the FIN state negotiation early). I've
> never observed an effect on the TCP time-wait states.

Definitely this is standard way to avoid time-wait states.

Maybe not very well documented. We probably should...

http://stackoverflow.com/questions/3757289/tcp-option-so-linger-zero-when-its-required




> Yes. SO_REUSEADDR has the problem that it requires you bind to
> something other than 0.0.0.0, so it is less appropriate for outgoing
> connections; the RPC code really should not have to worry about
> routing and routability of a particular source address.

OK understood.

Are you trying to reuse same 4-tuple ?



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
