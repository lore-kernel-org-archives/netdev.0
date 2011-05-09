From: Phil Sutter <phil@nwl.cc>
Subject: Re: ARM, AF_PACKET: caching problems on Marvell Kirkwood
Date: Mon, 9 May 2011 10:59:42 +0200
Message-ID: <20110509085942.GA3439@orbit.nwl.cc>
References: <20110408130643.GA8730@orbit.nwl.cc>
 <20110505141107.GC30443@orbit.nwl.cc>
 <20110505194601.GA10565@lunn.ch>
 <20110506161753.GC20777@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	ne@erfurth.eu, Johann Baudy <johann.baudy@gnu-log.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Nicolas Pitre <nico@fl
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.141.167]:48408 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab1EII7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 04:59:44 -0400
Content-Disposition: inline
In-Reply-To: <20110506161753.GC20777@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, May 06, 2011 at 06:17:53PM +0200, Phil Sutter wrote:
> On Thu, May 05, 2011 at 09:46:01PM +0200, Andrew Lunn wrote:
> > I can reproduce it on a Kirkwood:
> > 
> > [    0.000000] CPU: Feroceon 88FR131 [56251311] revision 1 (ARMv5TE), cr=00053977
> 
> Thanks for the information. Seems like we have the same CPU:
> 
> | [    0.000000] CPU: Feroceon 88FR131 [56251311] revision 1 (ARMv5TE), cr=00053177
> | [    0.000000] CPU: VIVT data cache, VIVT instruction cache
> 
> and it's actually VIVT, not VIPT as I wrote in an earlier mail.

Interesting news, a friend of mine can reproduce the problem on a
Foxboard (FOXG20):

| root@localhost:/root # dmesg |head -4
| [    0.000000] Linux version 2.6.37 (wbx@chrom) (gcc version 4.5.2 (GCC) ) #1 Sat May 7 19:37:30 CEST 2011
| [    0.000000] CPU: ARM926EJ-S [41069265] revision 5 (ARMv5TEJ), cr=00053177
| [    0.000000] CPU: VIVT data cache, VIVT instruction cache
| [    0.000000] Machine: Acme Systems FOXG20
| root@localhost:/root # uname -a
| Linux localhost 2.6.37 #1 Sat May 7 19:37:30 CEST 2011 armv5tejl GNU/Linux
| root@localhost:/root # /mmap
| sendto(): nothing sent!
| tp_status after sending: SEND_REQUEST
| sendto(): nothing sent!
| tp_status after sending: SEND_REQUEST
| sendto(): sent 450 bytes out
| tp_status after sending: AVAILABLE
| sendto(): sent 150 bytes out
| tp_status after sending: AVAILABLE
| sendto(): nothing sent!
| tp_status after sending: SEND_REQUEST
| sendto(): nothing sent!
| tp_status after sending: SEND_REQUEST
| sendto(): sent 300 bytes out
| tp_status after sending: SEND_REQUEST
| sendto(): nothing sent!
| tp_status after sending: SEND_REQUEST
| sendto(): sent 300 bytes out
| tp_status after sending: SEND_REQUEST
| sendto(): sent 150 bytes out
| tp_status after sending: SEND_REQUEST
| sendto(): sent 150 bytes out
| tp_status after sending: SEND_REQUEST
| sendto(): sent 300 bytes out
| tp_status after sending: AVAILABLE
| sendto(): nothing sent!
| tp_status after sending: SEND_REQUEST
| sendto(): sent 150 bytes out
| tp_status after sending: SEND_REQUEST

Greetings, Phil
