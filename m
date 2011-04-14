From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 14 Apr 2011 18:56:42 +0200
Message-ID: <1302800202.2035.32.camel@laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302253651.4409.2.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	 <1302267400.4409.22.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
	 <1302275223.4409.36.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>
	 <1302330998.2656.113.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>
	 <4DA3151B.4030507@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E4909714@ESGSCCMS0001.eapac.ericsson.se>
	 <1302536577.4605.1.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E49535F2@ESGSCCMS0001.eapac.ericsson.se>
	 <1302761251.3549.198.camel@edumazet-laptop>
	 <1302762810.3549.233.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E49536AF@ESGSCCMS0001.eapac.ericsson.se>
	 <4DA723F1.7000901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Gu <wei.gu@ericsson.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Mike Galbraith <efault@gmx.de>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:59665 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab1DNQyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 12:54:17 -0400
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1QAPo8-0002Hh-Mc
	for netdev@vger.kernel.org; Thu, 14 Apr 2011 16:54:16 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1QAPo7-0007SB-JW
	for netdev@vger.kernel.org; Thu, 14 Apr 2011 16:54:15 +0000
In-Reply-To: <4DA723F1.7000901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-14 at 09:42 -0700, Alexander Duyck wrote:

> I'm doing some more digging into this now.  One thought that occurred to 
> me is that if the patch you mention is having some sort of effect this 
> could be a sign of perhaps a kernel timer or scheduling problem.

Right, so the removal of the NO_HZ throttle will allow the CPU to go
into C states more often, this could result in longer wake-up times for
IRQs.

We reverted because:
  - it caused significant battery drain due to not going into C states
    often enough, and
  - its a much better idea to implement these things in the idle
    governor since it already has the job of guestimating the idle
    duration.

I really can't remember back far enough to even come up with a theory of
why kernels prior to merging the NO_HZ throttle would not exhibit this
problem.



