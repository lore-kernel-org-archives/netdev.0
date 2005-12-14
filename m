From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 21:16:28 +0100
Message-ID: <9a8748490512141216x7e25ca2cucb675f11f0c9d913@mail.gmail.com>
References: <Pine.LNX.4.58.0512140042280.31720@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964925AbVLNUQa@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0512140042280.31720@w-sridhar.beaverton.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/14/05, Sridhar Samudrala <sri@us.ibm.com> wrote:
>
> These set of patches provide a TCP/IP emergency communication mechanism that
> could be used to guarantee high priority communications over a critical socket
> to succeed even under very low memory conditions that last for a couple of
> minutes. It uses the critical page pool facility provided by Matt's patches
> that he posted recently on lkml.
>         http://lkml.org/lkml/2005/12/14/34/index.html
>
> This mechanism provides a new socket option SO_CRITICAL that can be used to
> mark a socket as critical. A critical connection used for emergency

So now everyone writing commercial apps for Linux are going to set
SO_CRITICAL on sockets in their apps so their apps can "survive better
under pressure than the competitors aps" and clueless programmers all
over are going to think "cool, with this I can make my app more
important than everyone elses, I'm going to use this".  When everyone
and his dog starts to set this, what's the point?


> communications has to be established and marked as critical before we enter
> the emergency condition.
>
> It uses the __GFP_CRITICAL flag introduced in the critical page pool patches
> to indicate an allocation request as critical and should be satisfied from the
> critical page pool if required. In the send path, this flag is passed with all
> allocation requests that are made for a critical socket. But in the receive
> path we do not know if a packet is critical or not until we receive it and
> find the socket that it is destined to. So we treat all the allocation
> requests in the receive path as critical.
>
> The critical page pool patches also introduces a global flag
> 'system_in_emergency' that is used to indicate an emergency situation(could be
> a low memory condition). When this flag is set any incoming packets that belong
> to non-critical sockets are dropped as soon as possible in the receive path.

Hmm, so if I fire up an app that has SO_CRITICAL set on a socket and
can then somehow put a lot of memory pressure on the machine I can
cause traffic on other sockets to be dropped.. hmmm.. sounds like
something to play with to create new and interresting DoS attacks...


> This is necessary to prevent incoming non-critical packets to consume memory
> from critical page pool.
>
> I would appreciate any feedback or comments on this approach.
>

To be a little serious, it sounds like something that could be used to
cause trouble and something that will lose its usefulness once enough
people start using it (for valid or invalid reasons), so what's the
point...


--
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
