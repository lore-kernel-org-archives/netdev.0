From: Ronghua Zhang <rz5b@cs.virginia.edu>
Subject: Re: [PATCH] proportional share accept()
Date: Thu, 26 Feb 2004 17:08:23 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.51.0402261659350.24561@mamba.cs.Virginia.EDU>
References: <Pine.LNX.4.44.0402251119060.3691-100000@dyn319495.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, shemminger@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kashyapv <kashyapv@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0402251119060.3691-100000@dyn319495.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is another option. We can either start multiple instances of the
applications on different ports, or modify the application to listen to
several ports. All these ports are not the well-known service ports, and
not visible to the clients. Instead, the kernel creates a 'steathy' listen
socket on the well-known service port. After the connection is
established, based on some classification rules, the open_request
structure is moved from the accept queue of the 'steathy' socket to
the the accept queue of one socket the application is listening to.

This procedure is transparent to the client and the application. The
classification can be implemented as a module, and only a few places in
the kernel need to be touched.

I have a prototype implementation. You can check out
www.cs.virginia.edu/~rz5b/research/kernel-qos.htm for details.

Ronghua

 On Wed, 25 Feb 2004, kashyapv wrote:

> On Wed, 25 Feb 2004, David S. Miller wrote:
>
> > On Wed, 25 Feb 2004 11:07:48 -0800 (PST)
> > kashyapv <kashyapv@us.ibm.com> wrote:
> >
> > > Also, an in-kernel solution allows administrative control and tuning
> > > without affecting the applications at all. The administrator can as per
> > > the policy (which may change over time) modify the proportions using another
> > > interface. Otherwise, each application must provide a way to manage/modify
> > > its scheduler.
> >
> > Since all of the classification we're suggesting is via the kernel, the
> > administrator has the same kinds of controls and it is also without any
> > application modifications.
>
> How do you change the scheduler's proportions? Not the classification
> itself which is controlled using iptables.
>
> >
> > We're saying, to classify packets so that they get prioritized however you
> > would have prioritized things in the accept queue (ie. mark SYN packets
> > with address X as having priority Y).  The let the packet scheduler or
> > netfilter take care of the rest.
>
> In the in-kernel accept queues the netfilter MARKs it and the packet
> is queued to the relevant accept queue. Where and how is the packet getting
> queued to a differnt socket (address mangling?)?
>
> >
> >
>
>
