From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 1/5] sctp: add the rhashtable apis for sctp
 global transport hashtable
Date: Mon, 11 Jan 2016 14:33:37 -0200
Message-ID: <20160111163337.GC6074@mrl.redhat.com>
References: <20151230.125046.310343849422003518.davem@davemloft.net>
 <20160111093210.GA23557@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, mleitner@redhat.com,
	vyasevic@redhat.com, daniel@iogearbox.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932457AbcAKQdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 11:33:41 -0500
Content-Disposition: inline
In-Reply-To: <20160111093210.GA23557@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 05:32:10PM +0800, Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 30 Dec 2015 11:57:31 -0500
> > 
> >> I am against using rhashtable in SCTP (or TCP) at this stage, given the
> >> number of bugs we have with it.
> > 
> > Come on Eric, we've largely dealt with all of these problems.  I haven't
> > seen a serious report in a while.
> 
> Well there is still the outstanding issue with softirq insertion
> potentially failing with ENOMEM if we fail to expand the hash
> table using just kmalloc.
> 
> So if the target user does softirq insertions, I would wait until
> the fix for that is ready.

It does some, yes. If listening socket is not backlogged, there will be
N inserts at each new association, where N is the number of IP addresses
that the client is advertising.

This is done on the second stage of the SCTP handshake. Not easily
DoS-able as it requires receiving a packet from server and replying
based on it, plus N is limited by MTU.

AFAIK Xin's stress tests couldn't hit this situation of ENOMEM, btw.

Thanks,
Marcelo
