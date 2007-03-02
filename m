From: "Ritesh Kumar" <ritesh@cs.unc.edu>
Subject: Re: Netem tfifo implementation
Date: Fri, 2 Mar 2007 15:56:54 -0500
Message-ID: <f47983b00703021256y78d2140ev3f4314f62c849844@mail.gmail.com>
References: <f47983b00703021101h344f58e6ife56c01b54f3adaf@mail.gmail.com>
	 <45E87FE6.1060503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:33302 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965614AbXCBU44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 15:56:56 -0500
Received: by wr-out-0506.google.com with SMTP id 37so506270wra
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 12:56:54 -0800 (PST)
In-Reply-To: <45E87FE6.1060503@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/2/07, Patrick McHardy <kaber@trash.net> wrote:
> Ritesh Kumar wrote:
> > Hi,
> >    I recently saw the qdisc "tfifo" in the netem module
> > (net/sched/sch_netem.c) when I migrated some of my patches from 2.6.14
> > to 2.6.20. As I understand, tfifo helps in keeping the queue of
> > packets sorted according to their "time_to_send". [tfifo was not
> > present in 2.6.14 perhaps because arrival order of packets was always
> > equal to the departure order]. However, tfifo uses a linear search in
> > the packet queue to find where to enqueue the packet.
> >    Quite some time ago (2.6.14 era), I needed a similar functionality
> > from the netem module and I ended up coding a pointer based min-heap
> > for the same. I was wondering if the community was interested in using
> > the min-heap implementation to replace the linear search
> > implementation. I have tested the min-heap quite a few times and it
> > seems to work.
> >    The implementation is slightly non-trivial because it uses
> > pointers to maintain the heap structure instead if using good old
> > fixed size arrays. I did this mainly so that the limit of the netem
> > qdisc could be changed on the fly. However, because every sk_buff now
> > needs two pointers for its children nodes, I added an extra
> > (sk_buff*)next2 to struct sk_buff (sorry!). However, this can probably
> > be changed to a pointer inside netem_skb_cb.  Also, because I needed
> > this for personal work and 2.6.14 didn't contain tfifo, I basically
> > removed the embedded qdisc and made netem a classless qdisc with my
> > min heap as the native "queue" (sorry again! :) )
>
> The tfifo qdisc has a limit, why not just allocate a fixed-size heap
> based on that?
>
>

The tfifo queue limit itself can be changed and that creates the
problem. If we use a fixed heap (say implemented using a fixed size
array) then we will have to copy over all pointers from the first
array to a reallocated array whenever the queue limit is changed.
In retrospect, moving just a few 10s of kilobytes of data doesn't seem
that much of a problem... now I feel stupid having put so much effort
:).

Ritesh
