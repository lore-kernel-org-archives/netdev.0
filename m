From: jamal <hadi@cyberus.ca>
Subject: Re: Linux SMP on 2.4.18-3
Date: Mon, 4 Nov 2002 08:10:37 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211040703400.25806-100000@shell.cyberus.ca>
References: <Pine.LNX.4.33L0.0210281020180.28869-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
In-Reply-To: <Pine.LNX.4.33L0.0210281020180.28869-100000@fast2.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 28 Oct 2002, Cheng Jin wrote:

> > The IP network stack in linux is totaly reentrant. You could have a
> > packet on _each_ processor in SMP concurently executing the same code. If
> > you add anything, you need to take this into account.
>
> We did add code to the TCP layer, but I don't exactly see anything in the
> original code where locking is used.  I assume the locks are in the IP
> layer and lower?

There are a few, but they are irrelevant in your case since you dont
touch that code (eg the dst cache lock).
As far as TCP is concerned, serialization between SMP processors happens
with the socket lock. This lock is also used to sequence packets
[Remember TCP has to ensure that packets are sequenced for processing
by user process. Also remember that TCP runs in both user and process
context].

> The weirdest thing is that we noticed in
> update_send_head, tp->packets_out sometimes increases by more than one
> even though the code ++ it only once.  I guess I am not sure how we could
> have screwed it up if the modifications are on the TCP layer.
>

Anything that you want to serialize access to you should put in the sock
struct; then use the sock lock to serialize.

cheers,
jamal
