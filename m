From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: NETDEV WATCHDOG: eth2: transmit timed out with 3c905C-TX
Date: Fri, 16 Jun 2006 14:44:06 +0200
Message-ID: <BAY103-F1352CA6533B089A11AD29CB2830@phx.gbl>
References: <20060606191326.GE14011@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay103-f13.bay103.hotmail.com ([65.54.174.23]:49668 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S1751385AbWFPMoL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 08:44:11 -0400
In-Reply-To: <20060606191326.GE14011@bayes.mathematik.tu-chemnitz.de>
To: klassert@mathematik.tu-chemnitz.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steffen Klassert wrote:

>On Tue, Jun 06, 2006 at 11:12:45AM +0200, Marco Berizzi wrote:
> >
> > I have moved this damn pc from the remote to my site and I have
> > placed it in production environment with 2.6.17-rc5
> > No problem after 24 hours (on the remote side the problem was
> > arising after a couple of hours). I have modprobed 3c59x with
> > debug=4. I see only these kind of messages (are they fine?):
> >
> > Jun  5 14:31:25 Pleiadi kernel: eth2: vortex_error(), status=0x8081
> > Jun  5 14:31:40 Pleiadi last message repeated 3 times
> > Jun  5 14:31:47 Pleiadi kernel: eth2: vortex_error(), status=0x8281
> > Jun  5 14:31:47 Pleiadi kernel: eth2: Media selection timer tick 
>happened,
> > Autonegotiate.
> > Jun  5 14:31:47 Pleiadi kernel: dev->watchdog_timeo=1250
> > Jun  5 14:31:47 Pleiadi kernel: eth2: MII transceiver has status 782d.
> > Jun  5 14:31:47 Pleiadi kernel: eth2: Media selection timer finished,
> > Autonegotiate.
> > Jun  5 14:31:51 Pleiadi kernel: eth2: vortex_error(), status=0x8081
> > Jun  5 14:32:03 Pleiadi last message repeated 2 times
> > Jun  5 14:32:10 Pleiadi kernel: eth2: vortex_error(), status=0x8481
> > Jun  5 14:32:15 Pleiadi kernel: eth2: vortex_error(), status=0x8081
> > Jun  5 14:32:46 Pleiadi last message repeated 7 times
>
>This is ok, just normal operation of the NIC.
>
> >
> > The only relevant change, between the remote and my site, is a
> > different ethernet switch where the 3c905C is connected to.
> > Could it be an issue?
>
>Well, I think it can. Problems with a switch are mostly related
>to the autonegotiation of the media type and full/half-duplex.
>But in your case the autonegotiation seems to be ok
>(mii-tool/ethtool output). More specific information you can
>get with the mii-diag and vortex-diag tools. You can find
>these tools at http://www.scyld.com/ethercard_diag.html
>
>There are problems with a cisco switch documented in
>Documentation/networking/vortex.txt for example.

[moved again this pc to the original site]

I have modprobed 3c59x with debug=6 and after
a while (about 100 minutes) this error has been
arised. Here is the log. Doy you see anything
relevant? I don't understand why running an
ifconfig eth2 down/up 'resolves' the issue for
another 100 minutes.

Jun 16 14:01:34 Teti kernel: eth2: interrupt, status 8401, latency 2 ticks.
Jun 16 14:01:34 Teti kernel: eth2: In interrupt loop, status 8401.
Jun 16 14:01:34 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:34 Teti kernel: boomerang_rx(): status 8001
Jun 16 14:01:34 Teti kernel: Receiving packet size 60 status a000803c.
Jun 16 14:01:34 Teti kernel: eth2: exiting interrupt, status 8000.
Jun 16 14:01:34 Teti kernel: eth2: interrupt, status 8401, latency 1 ticks.
Jun 16 14:01:34 Teti kernel: eth2: In interrupt loop, status 8401.
Jun 16 14:01:34 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:34 Teti kernel: boomerang_rx(): status 8001
Jun 16 14:01:34 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:01:34 Teti kernel: eth2: exiting interrupt, status 8000.
Jun 16 14:01:36 Teti kernel: eth2: interrupt, status 8401, latency 2 ticks.
Jun 16 14:01:36 Teti kernel: eth2: In interrupt loop, status 8401.
Jun 16 14:01:36 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:36 Teti kernel: boomerang_rx(): status 8001
Jun 16 14:01:36 Teti kernel: Receiving packet size 82 status 60008052.
Jun 16 14:01:36 Teti kernel: eth2: exiting interrupt, status 8000.
Jun 16 14:01:36 Teti kernel: eth2: interrupt, status 8401, latency 2 ticks.
Jun 16 14:01:36 Teti kernel: eth2: In interrupt loop, status 8401.
Jun 16 14:01:36 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:36 Teti kernel: boomerang_rx(): status 8001
Jun 16 14:01:36 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:01:36 Teti kernel: eth2: exiting interrupt, status 8000.
Jun 16 14:01:38 Teti kernel: eth2: interrupt, status 8401, latency 2 ticks.
Jun 16 14:01:38 Teti kernel: eth2: In interrupt loop, status 8401.
Jun 16 14:01:38 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:38 Teti kernel: boomerang_rx(): status 8001
Jun 16 14:01:38 Teti kernel: Receiving packet size 60 status 6000803c.
Jun 16 14:01:38 Teti kernel: eth2: exiting interrupt, status 8000.
Jun 16 14:01:39 Teti kernel: NETDEV WATCHDOG: eth2: transmit timed out
Jun 16 14:01:39 Teti kernel: eth2: transmit timed out, tx_status 00 status 
8000.
Jun 16 14:01:39 Teti kernel:   diagnostics: net 0ccc media 8880 dma 000000a0 
fifo 0000
Jun 16 14:01:39 Teti kernel:   Flags; bus-master 1, dirty 10411(11) current 
10427(11)
Jun 16 14:01:39 Teti kernel:   Transmit list 159258e0 vs. d59258e0.
Jun 16 14:01:39 Teti kernel:   0: @d5925200  length 80000086 status 00000086
Jun 16 14:01:39 Teti kernel:   1: @d59252a0  length 800000ec status 000000ec
Jun 16 14:01:39 Teti kernel:   2: @d5925340  length 8000003f status 0000003f
Jun 16 14:01:39 Teti kernel:   3: @d59253e0  length 800000ec status 000000ec
Jun 16 14:01:39 Teti kernel:   4: @d5925480  length 8000003f status 0000003f
Jun 16 14:01:39 Teti kernel:   5: @d5925520  length 800000ec status 000000ec
Jun 16 14:01:39 Teti kernel:   6: @d59255c0  length 8000002a status 0000002a
Jun 16 14:01:39 Teti kernel:   7: @d5925660  length 8000003f status 0000003f
Jun 16 14:01:39 Teti kernel:   8: @d5925700  length 800000ec status 000000ec
Jun 16 14:01:39 Teti kernel:   9: @d59257a0  length 800000ec status 800000ec
Jun 16 14:01:39 Teti kernel:   10: @d5925840  length 800000ec status 
800000ec
Jun 16 14:01:39 Teti kernel:   11: @d59258e0  length 8000082a status 
0000082a
Jun 16 14:01:39 Teti kernel:   12: @d5925980  length 80000086 status 
00000086
Jun 16 14:01:39 Teti kernel:   13: @d5925a20  length 80000037 status 
00000037
Jun 16 14:01:39 Teti kernel:   14: @d5925ac0  length 80000036 status 
00000036
Jun 16 14:01:39 Teti kernel:   15: @d5925b60  length 8000003f status 
0000003f
Jun 16 14:01:39 Teti kernel: eth2: Resetting the Tx ring pointer.
Jun 16 14:01:39 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:39 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:39 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:39 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:39 Teti kernel: Receiving packet size 82 status 60008052.
Jun 16 14:01:39 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:41 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:41 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:41 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:41 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:41 Teti kernel: Receiving packet size 82 status a0008052.
Jun 16 14:01:41 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:42 Teti kernel: eth2: interrupt, status e401, latency 1 ticks.
Jun 16 14:01:42 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:42 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:42 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:42 Teti kernel: Receiving packet size 82 status a0008052.
Jun 16 14:01:42 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:43 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:43 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:43 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:43 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:43 Teti kernel: Receiving packet size 82 status a0008052.
Jun 16 14:01:43 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:44 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:44 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:44 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:44 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:44 Teti kernel: Receiving packet size 92 status a000805c.
Jun 16 14:01:44 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:44 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:44 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:44 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:44 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:44 Teti kernel: Receiving packet size 243 status a00080f3.
Jun 16 14:01:44 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:45 Teti kernel: eth2: interrupt, status e401, latency 1 ticks.
Jun 16 14:01:45 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:45 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:45 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:45 Teti kernel: Receiving packet size 92 status a000805c.
Jun 16 14:01:45 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:45 Teti kernel: eth2: interrupt, status e401, latency 5 ticks.
Jun 16 14:01:45 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:45 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:45 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:45 Teti kernel: Receiving packet size 60 status 6000803c.
Jun 16 14:01:45 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:45 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:45 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:45 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:45 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:45 Teti kernel: Receiving packet size 76 status a000804c.
Jun 16 14:01:45 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:46 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:46 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:46 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:46 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:46 Teti kernel: Receiving packet size 92 status a000805c.
Jun 16 14:01:46 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:46 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:46 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:46 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:46 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:46 Teti kernel: Receiving packet size 247 status a00080f7.
Jun 16 14:01:46 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:46 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:46 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:46 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:46 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:46 Teti kernel: Receiving packet size 247 status a00080f7.
Jun 16 14:01:46 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:46 Teti kernel: eth2: interrupt, status e401, latency 1 ticks.
Jun 16 14:01:46 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:46 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:46 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:46 Teti kernel: Receiving packet size 76 status a000804c.
Jun 16 14:01:46 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:47 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:47 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:47 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:47 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:47 Teti kernel: Receiving packet size 82 status 60008052.
Jun 16 14:01:47 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:47 Teti kernel: eth2: interrupt, status e401, latency 1 ticks.
Jun 16 14:01:47 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:47 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:47 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:47 Teti kernel: Receiving packet size 76 status a000804c.
Jun 16 14:01:47 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:48 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:01:48 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:01:48 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:01:48 Teti kernel: boomerang_rx(): status e001
Jun 16 14:01:48 Teti kernel: Receiving packet size 60 status 6000803c.
Jun 16 14:01:48 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:01:49 Teti kernel: NETDEV WATCHDOG: eth2: transmit timed out
Jun 16 14:01:49 Teti kernel: eth2: transmit timed out, tx_status 00 status 
e000.
Jun 16 14:01:49 Teti kernel:   diagnostics: net 0ccc media 8880 dma 000000a0 
fifo 0000
Jun 16 14:01:49 Teti kernel:   Flags; bus-master 1, dirty 10411(11) current 
10427(11)
Jun 16 14:01:49 Teti kernel:   Transmit list 159258e0 vs. d59258e0.

Here is the log when I run ifconfig eth2 down
and ifconfig eth2 up:

Jun 16 14:19:49 Teti kernel: NETDEV WATCHDOG: eth2: transmit timed out
Jun 16 14:19:49 Teti kernel: eth2: transmit timed out, tx_status 00 status 
e000.
Jun 16 14:19:49 Teti kernel:   diagnostics: net 0ccc media 8880 dma 000000a0 
fifo 0000
Jun 16 14:19:49 Teti kernel:   Flags; bus-master 1, dirty 10411(11) current 
10427(11)
Jun 16 14:19:49 Teti kernel:   Transmit list 159258e0 vs. d59258e0.
Jun 16 14:19:49 Teti kernel:   0: @d5925200  length 80000086 status 00000086
Jun 16 14:19:49 Teti kernel:   1: @d59252a0  length 800000ec status 000000ec
Jun 16 14:19:49 Teti kernel:   2: @d5925340  length 8000003f status 0000003f
Jun 16 14:19:49 Teti kernel:   3: @d59253e0  length 800000ec status 000000ec
Jun 16 14:19:49 Teti kernel:   4: @d5925480  length 8000003f status 0000003f
Jun 16 14:19:49 Teti kernel:   5: @d5925520  length 800000ec status 000000ec
Jun 16 14:19:49 Teti kernel:   6: @d59255c0  length 8000002a status 0000002a
Jun 16 14:19:49 Teti kernel:   7: @d5925660  length 8000003f status 0000003f
Jun 16 14:19:49 Teti kernel:   8: @d5925700  length 800000ec status 000000ec
Jun 16 14:19:49 Teti kernel:   9: @d59257a0  length 800000ec status 800000ec
Jun 16 14:19:49 Teti kernel:   10: @d5925840  length 800000ec status 
800000ec
Jun 16 14:19:49 Teti kernel:   11: @d59258e0  length 8000082a status 
0000082a
Jun 16 14:19:49 Teti kernel:   12: @d5925980  length 80000086 status 
00000086
Jun 16 14:19:49 Teti kernel:   13: @d5925a20  length 80000037 status 
00000037
Jun 16 14:19:49 Teti kernel:   14: @d5925ac0  length 80000036 status 
00000036
Jun 16 14:19:49 Teti kernel:   15: @d5925b60  length 8000003f status 
0000003f
Jun 16 14:19:49 Teti kernel: eth2: Resetting the Tx ring pointer.
Jun 16 14:19:49 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:49 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:49 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:49 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:49 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:19:49 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:49 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:49 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:49 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:49 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:49 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:19:49 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:50 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:50 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:50 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:50 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:50 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:19:50 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:51 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:51 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:51 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:51 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:51 Teti kernel: Receiving packet size 71 status a0008047.
Jun 16 14:19:51 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:51 Teti kernel: eth2: interrupt, status e401, latency 1 ticks.
Jun 16 14:19:51 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:51 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:51 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:51 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:19:51 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:51 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:51 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:51 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:51 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:51 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:19:51 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:52 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:52 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:52 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:52 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:52 Teti kernel: Receiving packet size 71 status a0008047.
Jun 16 14:19:52 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:52 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:52 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:52 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:52 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:52 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:19:52 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:53 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:53 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:53 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:53 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:53 Teti kernel: Receiving packet size 71 status a0008047.
Jun 16 14:19:53 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:53 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:53 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:53 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:53 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:53 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:19:53 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:54 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:54 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:54 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:54 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:54 Teti kernel: Receiving packet size 92 status a000805c.
Jun 16 14:19:54 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:54 Teti kernel: eth2: interrupt, status e401, latency 2 ticks.
Jun 16 14:19:54 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:54 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:54 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:54 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:19:54 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:54 Teti kernel: eth2: interrupt, status e401, latency 1 ticks.
Jun 16 14:19:54 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:54 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:54 Teti kernel: boomerang_rx(): status e001
Jun 16 14:19:54 Teti kernel: Receiving packet size 60 status 803c.
Jun 16 14:19:54 Teti kernel: eth2: exiting interrupt, status e000.
Jun 16 14:19:55 Teti kernel: eth2: vortex_close() status e000, Tx status 00.
Jun 16 14:19:55 Teti kernel: eth2: vortex close stats: rx_nocopy 10191 
rx_copy 46830 tx_queued 51612 Rx pre-checksummed 52779.
Jun 16 14:19:57 Teti kernel: eth2:  Filling in the Rx ring.
Jun 16 14:19:57 Teti kernel: PCI: Found IRQ 7 for device 0000:01:09.0
Jun 16 14:19:57 Teti kernel: eth2: using NWAY device table, not 8
Jun 16 14:19:57 Teti kernel: eth2: Initial media type Autonegotiate.
Jun 16 14:19:57 Teti kernel: eth2: link up, 100Mbps, full-duplex, lpa 0x45E1
Jun 16 14:19:57 Teti kernel: eth2:  setting full-duplex.
Jun 16 14:19:57 Teti kernel: eth2: vortex_up() irq 7 media status 8880.
Jun 16 14:19:57 Teti kernel: eth2: interrupt, status e401, latency 1 ticks.
Jun 16 14:19:57 Teti kernel: eth2: In interrupt loop, status e401.
Jun 16 14:19:57 Teti kernel: boomerang_interrupt->boomerang_rx
Jun 16 14:19:57 Teti kernel: boomerang_rx(): status e001

PS: linux is vanilla 2.6.17-rc6


