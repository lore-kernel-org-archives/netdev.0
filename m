From: Matt Mackall <mpm@selenic.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Tue, 29 Mar 2005 14:17:43 -0800
Message-ID: <20050329221743.GK15453@waste.org>
References: <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <Pine.LNX.4.61.0503291659290.15625@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        Andi Kleen <ak@muc.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        andrea@suse.de, michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        ksummit-2005-discuss@thunk.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rik van Riel <riel@redhat.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0503291659290.15625@chimarrao.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2005 at 05:00:35PM -0500, Rik van Riel wrote:
> On Tue, 29 Mar 2005, jamal wrote:
> 
> > If yes, the solution maybe to just drop all non-high-prio packets coming
> > in during the denial of service attack (for lack of better term). In
> > other words some strict prioritization scheduling (or rate control) at
> > the network level either in the NIC or ingress qdisc level.
> 
> Exactly, that is the proposal.  However, we often will need
> to get the packets off the network card before we can decide
> whether or not they're high priority.
> 
> Also, there can be multiple high priority sockets, and we
> need to ensure they all make progress.  Hence the mempool
> idea.

I'm sure Rik realizes this, but it's important to note here that
"making progress" may require M acknowledgements to N packets
representing a single IO. So we need separate send and acknowledge
pools for each SO_MEMALLOC socket so that we don't find ourselves
wedged with M-1 available mempool slots when we're waiting on ACKs. So
accounting ACK packets to the appropriate receiver once we've figured
out what socket an ACK is intended for is critical.

Note that ACK here is the application layer command result that needs
to be propagated back to the driver (and possibly higher in the case
of things like CD writing over iSCSI) and not simply a bit in the TCP
header.

-- 
Mathematics is the supreme nostalgia of our time.
