From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sat, 02 Aug 2008 12:18:15 -0700 (PDT)
Message-ID: <20080802.121815.167998262.davem@davemloft.net>
References: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8ADD@rrsmsx501.amr.corp.intel.com>
	<20080802133719.GB2970@ami.dom.local>
	<20080802162733.GA10059@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33012
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751293AbYHBTSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 15:18:15 -0400
In-Reply-To: <20080802162733.GA10059@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 2 Aug 2008 18:27:33 +0200

> On Sat, Aug 02, 2008 at 03:37:19PM +0200, Jarek Poplawski wrote:
> ...
> > I guess this "root lock" has to go back to netdev_queue. Alas, I can't
> > test this, so if it's not a big problem maybe you could try this patch
> > before David goes back to this? (His patch should be removed before
> > using this one.)
> 
> Actually, this patch was incomplete, sorry. Here is a better one,
> I hope. But of course, now, even better is to wait for David's
> proposal.

Jarek, we can't put the root lock back into the netdev_queue, it
breaks all of the RCU handling of qdisc_destroy() which is fundamental
for how all the multiqueue stuff works now.

See my other emails, it isn't even necessary anyways.
