From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: [PATCH 1/2]: [NET_SCHED]: Make all rate based scheduler work
	with TSO.
Date: Wed, 05 Sep 2007 11:17:10 +0200
Message-ID: <1188983830.16405.21.camel@localhost.localdomain>
References: <1188562975.18622.11.camel@localhost.localdomain>
	 <46D9103B.7090905@trash.net>
	 <Pine.LNX.4.61.0709012325080.29796@ask.diku.dk>
	 <20070903233456.0e738183.billfink@mindspring.com>
	 <46DD867E.6020307@trash.net>
	 <20070904134015.18a3e7ca.billfink@mindspring.com>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:49461 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755520AbXIEJQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 05:16:56 -0400
In-Reply-To: <20070904134015.18a3e7ca.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-04 at 13:40 -0400, Bill Fink wrote:
> On Tue, 04 Sep 2007, Patrick McHardy wrote:
> 
> > Bill Fink wrote:
> > > On Sat, 1 Sep 2007, Jesper Dangaard Brouer wrote:
> > >
> > Yes, you need to specify the MTU on the command line for
> > jumbo frames.
> 
> Thanks!  Works much better now, although it does slightly exceed
> the specified rate.

Thats what happens, with the current rate table system, as we use the
lower boundry (when doing the packet to time lookups). Especially with a
high MTU, as the "resolution" of the rate table diminish (mpu=9000 gives
cell_log=6, 2^6=64 bytes "resolution" buckets).

> [root@lang4 ~]# tc qdisc add dev eth2 root tbf rate 2gbit buffer 5000000 limit 18000 mtu 9000
> 
> [root@lang4 ~]# ./nuttcp-5.5.5 -w10m 192.168.88.14
>  2465.6729 MB /  10.08 sec = 2051.8241 Mbps 19 %TX 13 %RX
> 
> [root@lang4 ~]# ./nuttcp-5.5.5 -M1460 -w10m 192.168.88.14
>  2785.5000 MB /  10.00 sec = 2335.6569 Mbps 100 %TX 26 %RX

BTW, thats a fast connection you are having! :-)

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
