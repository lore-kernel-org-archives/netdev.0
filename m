From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 3/6] random32: add prandom_reseed_late() and
 call when nonblocking pool becomes initialized
Date: Tue, 12 Nov 2013 13:04:02 +0100
Message-ID: <1384257842.14301.7.camel@jlt4.sipsolutions.net>
References: <cover.1384160397.git.dborkman@redhat.com>
	 <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com>
	 <20131111134357.GC10104@thunk.org>
	 <20131112000307.GB14929@order.stressinduktion.org>
	 <20131112115350.GA14077@thunk.org> (sfid-20131112_125411_173736_4A7C850F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	shemminger@networkplumber.org, fweimer@redhat.com,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-wireless@vger.kernel.org
To: Theodore Ts'o <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:40026 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab3KLMEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 07:04:14 -0500
In-Reply-To: <20131112115350.GA14077@thunk.org> (sfid-20131112_125411_173736_4A7C850F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-12 at 06:53 -0500, Theodore Ts'o wrote:
> On Tue, Nov 12, 2013 at 01:03:07AM +0100, Hannes Frederic Sowa wrote:
> >
> > We are much too early to enumerate hardware, so it would be hard to
> > integrate something like mac addresses etc.
> 
> Stupid question --- is there a reason why the minstrel code is
> initialized so early when it is compiled into the kernel?  Can we
> change it so it gets initialized later, after the devices are
> initialized and we get the mac addresses?  

It's a bit of a chicken & egg problem - the minstrel rate control is
needed for the wireless device to get registered - if anything were to
fail there then we wouldn't want to register.

johannes
