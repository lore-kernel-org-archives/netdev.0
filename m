From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LSM networking: tcp hooks for 2.5.59 (8/8)
Date: Thu, 30 Jan 2003 16:16:38 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030130.161638.83467438.davem@redhat.com>
References: <20030130.152558.81554884.davem@redhat.com>
	<Pine.LNX.4.44.0301311113190.32098-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Pine.LNX.4.44.0301311113190.32098-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Fri, 31 Jan 2003 11:15:22 +1100 (EST)

   On Thu, 30 Jan 2003, David S. Miller wrote:
   
   > I totally reject this networking security stuff for 2.6.x
   
   Ok.  Thanks for looking at it.
   
James, do not take my comments too harshly please.

I realize the amount of work that went into these
changes and I do appreciate that.

The big problem is that the TCP bits had no apparent attempt to
abstract things out.  What is going to happen, for example, when net
protocol FOO makes mini-sockets too?  Will we make more
security_FOO_*() hooks or will we get smart and abstract this
technique somehow?

See, if I saw things like:

	openreq = sock_make_minisock(sizeof(struct openreq));

then the changes would be more acceptable.

The net/socket.c stuff looks fine.  All the stuff that makes decisions
based upon packets is highly questionable.  Netfilter can do all of
this work, it even has connection tracking infrastructure for TCP
connections.

I think with the net/socket.c stuff to take care of the user
side and some ingenious netfilter hacks for the packet side,
you could accomplish everything you need for the security stuff.

If you think this is implementable, then I'll happily accept the
net/socket.c stuff and even the af_unix hack, with the assumption
being that the rest can be handled by netfilter or something similar.
Oh yes, I'd also take the netlink capability thing too as long as it
was inlined properly for the no-security case.
