From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Date: Fri, 19 Jun 2015 22:44:29 -0400
Message-ID: <CAHQdGtQWx8udzG6VT8NwX5eWoDgnfyx7B-n-+75kakXf=a-F1g@mail.gmail.com>
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
	<20150619181440.22f54e6a@gandalf.local.home>
	<1434756359.8498.2.camel@primarydata.com>
	<20150619212706.2f13a44e@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Bruce James Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150619212706.2f13a44e-f9ZlEuEWxVcJvu8Pb33WZ0EMvNT87kid@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 19, 2015 at 9:27 PM, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> On Fri, 19 Jun 2015 19:25:59 -0400
> Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> wrote:
>
>
>> 8<--------------------------------------------------------------
>> >From 4876cc779ff525b9c2376d8076edf47815e71f2c Mon Sep 17 00:00:00 2001
>> From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
>> Date: Fri, 19 Jun 2015 16:17:57 -0400
>> Subject: [PATCH v2] SUNRPC: Ensure we release the TCP socket once it has been
>>  closed
>>
>> This fixes a regression introduced by commit caf4ccd4e88cf2 ("SUNRPC:
>> Make xs_tcp_close() do a socket shutdown rather than a sock_release").
>> Prior to that commit, the autoclose feature would ensure that an
>> idle connection would result in the socket being both disconnected and
>> released, whereas now only gets disconnected.
>>
>> While the current behaviour is harmless, it does leave the port bound
>> until either RPC traffic resumes or the RPC client is shut down.
>
> Is there a way to test RPC traffic resuming? I'd like to try that before
> declaring this bug harmless.

You should be seeing the same issue if you mount an NFSv3 partition.
After about 5 minutes of inactivity, the client will close down the
connection to the server, and rkhunter should again see the phantom
socket. If you then try to access the partition, the RPC layer should
immediately release the socket and establish a new connection on the
same port.

Cheers
  Trond
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
