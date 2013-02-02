From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid
 with wfica
Date: Sat, 2 Feb 2013 16:28:32 +0200
Message-ID: <20130202142832.GP8912@reaktio.net>
References: <20130123161238.GE8912@reaktio.net>
 <20130123214445.GA16641@order.stressinduktion.org>
 <20130123215151.GF8912@reaktio.net>
 <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
 <20130123234116.GC16641@order.stressinduktion.org>
 <1358984831.12374.1227.camel@edumazet-glaptop>
 <20130124135120.GD16641@order.stressinduktion.org>
 <1359777110.30177.58.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tele.fi ([192.89.123.25]:41980 "EHLO smtp.tele.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752932Ab3BBO2g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2013 09:28:36 -0500
Content-Disposition: inline
In-Reply-To: <1359777110.30177.58.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2013 at 07:51:50PM -0800, Eric Dumazet wrote:
> On Thu, 2013-01-24 at 14:51 +0100, Hannes Frederic Sowa wrote:
> > On Wed, Jan 23, 2013 at 03:47:11PM -0800, Eric Dumazet wrote:
> 
> > > Adding some BUG_ON(!tp->snd_cwnd) on every writes to tp->snd_cwnd should
> > > catch the bug.
> > 
> > But this is much more convenient, yes. :)
> 
> So I did that, and the winner is tcp_process_frto()
> 
>                 if (!(flag & FLAG_DATA_ACKED) && (tp->frto_counter == 1)) {
>                         /* Prevent sending of new data. */
>                         tp->snd_cwnd = min(tp->snd_cwnd,
>                                            tcp_packets_in_flight(tp));
>                         return true;
>                 }
> 
> I'll send two patches for net tree, and the debugging patch for net-next
> 

Great! Thanks for doing this. I didn't manage to find the time to do it myself yet :)

I'm happy to test the patches.

-- Pasi
