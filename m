From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH] inet: fix enforcing of fragment queue hash list
 depth
Date: Mon, 15 Apr 2013 19:12:23 +0200
Message-ID: <1366045943.11284.67.camel@localhost>
References: <20130415142454.14020.18322.stgit@dragon>
	 <20130415152637.GA29378@order.stressinduktion.org>
	 <1366043030.4459.109.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768Ab3DORM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 13:12:29 -0400
In-Reply-To: <1366043030.4459.109.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-15 at 09:23 -0700, Eric Dumazet wrote:

> Allowing thousand of fragments and keeping a 64 slot hash table is not
> going to work.
> 
> depths of 128 are just insane.

I fully agree, my plan was actually to reduce this to 5 or 10 depth
limit.  I just noticed this problem with Hannes patch, while working on
your idea of direct hash cleaning, and then I just/only extracted the
parts that was relevant for fixing Hannes patch.


> Really Jesper, you'll need to make the hash table dynamic, if you really
> care.

My plan/idea is to make the hash tables size depend on the available
memory.  As on small memory devices, we are opening up for (an attack
vector where) remote hosts can pin-down a large portion of their memory,
which we want to avoid.  (And you don't even need a port in listen
state).

How dynamic do you want it?  Would initial sizing based on memory be
enough, or should I also add a proc/sysctl option for changing the hash
size from userspace?

--Jesper
