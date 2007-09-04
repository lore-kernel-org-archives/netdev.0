From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 1/2]: [NET_SCHED]: Make all rate based scheduler work
 with TSO.
Date: Tue, 4 Sep 2007 13:40:15 -0400
Message-ID: <20070904134015.18a3e7ca.billfink@mindspring.com>
References: <1188562975.18622.11.camel@localhost.localdomain>
	<46D9103B.7090905@trash.net>
	<Pine.LNX.4.61.0709012325080.29796@ask.diku.dk>
	<20070903233456.0e738183.billfink@mindspring.com>
	<46DD867E.6020307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, jdb@comx.dk,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:58761
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754839AbXIDRkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 13:40:23 -0400
In-Reply-To: <46DD867E.6020307@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 04 Sep 2007, Patrick McHardy wrote:

> Bill Fink wrote:
> > On Sat, 1 Sep 2007, Jesper Dangaard Brouer wrote:
> >
> >>On Sat, 1 Sep 2007, Patrick McHardy wrote:
> >>>
> >>>It still won't work properly with TSO (TBF for example already drops
> >>>oversized packets during ->enqueue), but its a good cleanup anyway.
> >>
> >>Then lets call it a cleanup of the L2T macros.  In the next step we will 
> >>fix the different schedulers, to use the ability to lookup larger sized 
> >>packets. (I did notice the TBF scheduler would drop oversized packets).
> > 
> > Hmmm.  I guess this is also why TBF doesn't seem to work with 9000 byte
> > jumbo frames.
> > 
> > [root@lang4 ~]# tc qdisc add dev eth2 root tbf rate 2gbit buffer 5000000 limit 18000
> 
> Yes, you need to specify the MTU on the command line for
> jumbo frames.

Thanks!  Works much better now, although it does slightly exceed
the specified rate.

[root@lang4 ~]# tc qdisc add dev eth2 root tbf rate 2gbit buffer 5000000 limit 18000 mtu 9000

[root@lang4 ~]# ./nuttcp-5.5.5 -w10m 192.168.88.14
 2465.6729 MB /  10.08 sec = 2051.8241 Mbps 19 %TX 13 %RX

[root@lang4 ~]# ./nuttcp-5.5.5 -M1460 -w10m 192.168.88.14
 2785.5000 MB /  10.00 sec = 2335.6569 Mbps 100 %TX 26 %RX

						-Bill
