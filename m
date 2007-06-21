From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiple queue hardware support
Date: Thu, 21 Jun 2007 16:27:10 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903147122@orsmsx414.amr.corp.intel.com>
References: <467AEE48.5050902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25898 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751842AbXFUX1M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 19:27:12 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467AEE48.5050902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> PJ Waskiewicz wrote:
> > I did not modify other users of netif_queue_stopped() in 
> > net/core/netpoll.c, net/core/dev.c, or net/core/pktgen.c, since no 
> > classification occurs for the skb being sent to the device.  
> > Therefore, packets should always be ending up in queue 0, 
> so there's no need to check the subqueue status either.
> >   
> 
> Thats not correct. Subqueue 0 may be full and the queue still running.
> 
> I'll look over the patches later.

I'm working something up to address this.  The last time I thought about
this, I had issues with software devices, such as loopback.  They
weren't allocating any subqueues at all, so they would call
netif_subqueue_stopped() and panic the kernel.  However, now with Dave's
request to index egress_subqueue, the first queue is allocated for
everyone, so loopback and other software devices should be happy.  Let
me put these checks back in, test it out, and resend if I don't see any
issues.

Sorry for the thrash,
-PJ Waskiewicz
