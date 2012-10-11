From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 12:28:25 +0000
Message-ID: <201210111228.25995.arnd@arndb.de>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk> <20121011103257.GO4625@n2100.arm.linux.org.uk> <1349952574.21172.8604.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	Jon Masters <jonathan@jonmasters.org>, netdev@vger.kernel.org,
	=?iso-8859-1?q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>,
	Rob Herring <robherring2@gmail.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:59214 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab2JKM2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 08:28:55 -0400
In-Reply-To: <1349952574.21172.8604.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 October 2012, Eric Dumazet wrote:
> On Thu, 2012-10-11 at 11:32 +0100, Russell King - ARM Linux wrote:
> > On Thu, Oct 11, 2012 at 12:22:06PM +0200, Eric Dumazet wrote:
> > > I took a look, and I dont see why/how gcc could use a ldm instruction
> > > 
> > > Doing so assumed the alignment of the structure was 8 bytes, but its
> > > not.
> > > 
> > > Networking stack mandates that IP headers are aligned on 4 bytes
> > > boundaries, not 8 bytes.
> > 
> > Err, no.  ldm is "load multiple" not "load double".  It loads multiple
> > 32-bit registers, and its requirement for non-faulting behaviour is for
> > the pointer to be 4 byte aligned.  However, "load double" requires 8
> > byte alignment.
> 
> So if you have an alignment fault, thats because IP header is not
> aligned on 4 bytes ?
> 
> If so a driver is buggy and must be fixed.
> 
> Please send us full stack trace

Rob Herring as the original reporter has dropped off the Cc list, adding
him back.

I assume that the calxeda xgmac driver is the culprit then. It uses
netdev_alloc_skb() rather than netdev_alloc_skb_ip_align() in
xgmac_rx_refill but it is not clear whether it does so intentionally
or by accident.

	Arnd
