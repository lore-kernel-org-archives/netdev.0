From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: RX problem in ibm_newemac driver
Date: Wed, 11 Mar 2009 07:50:01 +1100
Message-ID: <1236718202.7086.10.camel@pasglop>
References: <49B6C4A2.8060302@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Radensky <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59078 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752651AbZCJUuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 16:50:14 -0400
In-Reply-To: <49B6C4A2.8060302@embedded-sol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-03-10 at 21:50 +0200, Felix Radensky wrote:
> Hi,
> 
> I'm experiencing RX problem on custom board based on AMCC
> 405EXr processor. Channel 0 of EMAC is connected to 10/100
> Micrel KSZ8041NL PHY in MII mode. Ethernet works fine in
> u-boot (version 2009.01). In Linux (2.6.27) Ethernet works fine
> as well if EMAC was initialized in u-boot. It is enough to send
> ping from u-boot (even to non-existing host) to make things work
> in linux. But if u-boot takes kernel and ramdisk images from flash
> and does not initialize EMAC only TX side works in linux.

You should CC linuxppc-dev where you are more likely to find people to
help here.

> I can see that TX counters are incremented when pinging from
> EMAC side, but RX counters remain zero.  RX error counter
> in PHY is zero as well.  I've enabled debugging in EMAC
> driver and verified that RX EOB interrupt is not triggered.
> FER register in RGMII bridge is properly configured for MII
> mode on channel 0.  I've tried to dump EMAC registers using
> ethtool and got machine check exception.
> 
> I don't know what else could be done to identify the source of
> the problem. Any tips would be greatly appreciated.

I don't have a 405EXr here, but it smells like the old reset problem
when the link is down. Maybe we are missing code to force clocks on
405EXr when there's no link ?

Ben.


