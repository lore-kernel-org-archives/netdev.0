From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 1/5] sctp: add the rhashtable apis for sctp
 global transport hashtable
Date: Mon, 11 Jan 2016 16:19:57 -0200
Message-ID: <20160111181957.GD6074@mrl.redhat.com>
References: <20151230.125046.310343849422003518.davem@davemloft.net>
 <20160111093210.GA23557@gondor.apana.org.au>
 <20160111163337.GC6074@mrl.redhat.com>
 <5693EFB8.4090604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, mleitner@redhat.com,
	vyasevic@redhat.com, daniel@iogearbox.net
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932541AbcAKSUC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 13:20:02 -0500
Content-Disposition: inline
In-Reply-To: <5693EFB8.4090604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 01:08:56PM -0500, Vlad Yasevich wrote:
> On 01/11/2016 11:33 AM, Marcelo Ricardo Leitner wrote:
> > On Mon, Jan 11, 2016 at 05:32:10PM +0800, Herbert Xu wrote:
> >> David Miller <davem@davemloft.net> wrote:
> >>> From: Eric Dumazet <eric.dumazet@gmail.com>
> >>> Date: Wed, 30 Dec 2015 11:57:31 -0500
> >>>
> >>>> I am against using rhashtable in SCTP (or TCP) at this stage, given the
> >>>> number of bugs we have with it.
> >>>
> >>> Come on Eric, we've largely dealt with all of these problems.  I haven't
> >>> seen a serious report in a while.
> >>
> >> Well there is still the outstanding issue with softirq insertion
> >> potentially failing with ENOMEM if we fail to expand the hash
> >> table using just kmalloc.
> >>
> >> So if the target user does softirq insertions, I would wait until
> >> the fix for that is ready.
> > 
> > It does some, yes. If listening socket is not backlogged, there will be
> > N inserts at each new association, where N is the number of IP addresses
> > that the client is advertising.
> > 
> > This is done on the second stage of the SCTP handshake. Not easily
> > DoS-able as it requires receiving a packet from server and replying
> > based on it, plus N is limited by MTU.
> 
> How is N limited by MTU?  INIT and COOKIE chunks are allowed to exceed
> mtu and will be IP fragmented.  So it seems that N is limited by 65535-overhead,
> where overhead is all the headers plus the sctp cookie info.  That can
> be quite a lot of addresses.

Oups, you're right. One then can trigger quite some inserts with a
single new assoc attempt, yes.

  Marcelo
