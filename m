From: Ronghua Zhang <rz5b@cs.virginia.edu>
Subject: Re: synchronization between bottom half and user context
Date: Wed, 4 Dec 2002 10:31:49 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0212041029230.1399-100000@bobbidi.cs.virginia.edu>
References: <Pine.GSO.4.30.0212040749090.2731-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0212040749090.2731-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Do you mean that net_bh can be running on several CPU at the same time?
If it is juat a UP, can I say that socket system call and net_bh is always
serialized even without lock_sock()?

Ronghua

On Wed, 4 Dec 2002, jamal wrote:

>
>
> On Tue, 3 Dec 2002, Ronghua Zhang wrote:
>
> > Can someone tell me when lock should be used to synchronize bh and user
> > context?
> >
> > For examle: in tcp_accept(), lock_sock() is called to avoid any change
> > made by net_bh during its operation. But if tcp_accept() is called, it's
> > impossilbe that net_bh is also executing. (i think this is true for UP,
> > what about SMP?), then why need lock_sock()?
> >
>
> to serialize packets towards the socket; The linux network stack
> is threaded, you can have upto n packets to the same socket coming up the
> stack in parallel on an n-SMP machine; think of that and the fact that TCP
> data must be sequenced.
>
> cheers,
> jamal
>
