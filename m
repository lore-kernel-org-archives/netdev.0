From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid
 with wfica
Date: Fri, 01 Feb 2013 19:51:50 -0800
Message-ID: <1359777110.30177.58.camel@edumazet-glaptop>
References: <20130123161238.GE8912@reaktio.net>
	 <20130123214445.GA16641@order.stressinduktion.org>
	 <20130123215151.GF8912@reaktio.net>
	 <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
	 <20130123234116.GC16641@order.stressinduktion.org>
	 <1358984831.12374.1227.camel@edumazet-glaptop>
	 <20130124135120.GD16641@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:46413 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757464Ab3BBDv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 22:51:56 -0500
Received: by mail-da0-f50.google.com with SMTP id h15so1968935dan.23
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 19:51:54 -0800 (PST)
In-Reply-To: <20130124135120.GD16641@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-24 at 14:51 +0100, Hannes Frederic Sowa wrote:
> On Wed, Jan 23, 2013 at 03:47:11PM -0800, Eric Dumazet wrote:

> > Adding some BUG_ON(!tp->snd_cwnd) on every writes to tp->snd_cwnd should
> > catch the bug.
> 
> But this is much more convenient, yes. :)

So I did that, and the winner is tcp_process_frto()

                if (!(flag & FLAG_DATA_ACKED) && (tp->frto_counter == 1)) {
                        /* Prevent sending of new data. */
                        tp->snd_cwnd = min(tp->snd_cwnd,
                                           tcp_packets_in_flight(tp));
                        return true;
                }

I'll send two patches for net tree, and the debugging patch for net-next
