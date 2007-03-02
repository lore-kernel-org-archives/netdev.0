From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netem tfifo implementation
Date: Fri, 02 Mar 2007 20:49:58 +0100
Message-ID: <45E87FE6.1060503@trash.net>
References: <f47983b00703021101h344f58e6ife56c01b54f3adaf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ritesh Kumar <ritesh@cs.unc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48475 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964934AbXCBTuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 14:50:07 -0500
In-Reply-To: <f47983b00703021101h344f58e6ife56c01b54f3adaf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ritesh Kumar wrote:
> Hi,
>    I recently saw the qdisc "tfifo" in the netem module
> (net/sched/sch_netem.c) when I migrated some of my patches from 2.6.14
> to 2.6.20. As I understand, tfifo helps in keeping the queue of
> packets sorted according to their "time_to_send". [tfifo was not
> present in 2.6.14 perhaps because arrival order of packets was always
> equal to the departure order]. However, tfifo uses a linear search in
> the packet queue to find where to enqueue the packet.
>    Quite some time ago (2.6.14 era), I needed a similar functionality
> from the netem module and I ended up coding a pointer based min-heap
> for the same. I was wondering if the community was interested in using
> the min-heap implementation to replace the linear search
> implementation. I have tested the min-heap quite a few times and it
> seems to work.
>    The implementation is slightly non-trivial because it uses
> pointers to maintain the heap structure instead if using good old
> fixed size arrays. I did this mainly so that the limit of the netem
> qdisc could be changed on the fly. However, because every sk_buff now
> needs two pointers for its children nodes, I added an extra
> (sk_buff*)next2 to struct sk_buff (sorry!). However, this can probably
> be changed to a pointer inside netem_skb_cb.  Also, because I needed
> this for personal work and 2.6.14 didn't contain tfifo, I basically
> removed the embedded qdisc and made netem a classless qdisc with my
> min heap as the native "queue" (sorry again! :) )

The tfifo qdisc has a limit, why not just allocate a fixed-size heap
based on that?

