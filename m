From: Matt Mackall <mpm@selenic.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Tue, 29 Mar 2005 15:25:45 -0800
Message-ID: <20050329232545.GL15453@waste.org>
References: <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <Pine.LNX.4.61.0503291659290.15625@chimarrao.boston.redhat.com> <1112137210.1088.17.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rik van Riel <riel@redhat.com>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        Andi Kleen <ak@muc.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        andrea@suse.de, michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        ksummit-2005-discuss@thunk.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112137210.1088.17.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2005 at 06:00:11PM -0500, jamal wrote:
> On Tue, 2005-03-29 at 17:00, Rik van Riel wrote:
> 
> >   However, we often will need
> > to get the packets off the network card before we can decide
> > whether or not they're high priority.
> 
> True - although one could argue that with NAPI that decision would be a
> few opcodes away if you install the ingress qdisc. 
> So you may end up allocing only to free a few cycles later. Increased
> memory traffic but the discard happens sufficiently early for a s/ware
> only solution and CPU cycles not burnt as much.
[...]

I think we first need a software solution that makes no special
assumptions about hardware capabilities.
 
> > Also, there can be multiple high priority sockets, and we
> > need to ensure they all make progress.  Hence the mempool
> > idea.
> 
> Sorry missed the early part of this thread: mempool is some
> strict priority scheme for mem allocation?

A mempool is a private allocation pool that attempts to maintain a
reserve of N objects. Various users in the kernel already. See
mm/mempool.c.

> For Sockets: If there was a "control" arbitrator preferably in user
> space which would install - after a socket open - both network ingress
> and/or egress rules for prioritization then wouldnt that suffice?

Generally, we don't want any special handling except when we're
effectively OOM.

-- 
Mathematics is the supreme nostalgia of our time.
