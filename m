From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/2] NET: Multiqueue network device support implementation.
Date: Mon, 9 Apr 2007 14:52:12 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329029E400C@orsmsx414.amr.corp.intel.com>
References: <Pine.LNX.4.61.0704092332030.22295@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jgarzik@pobox.com>,
	"cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "Jan Engelhardt" <jengelh@linux01.gwdg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38117 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753047AbXDIVwP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 17:52:15 -0400
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.61.0704092332030.22295@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hi,
> 
> 
> On Apr 9 2007 14:28, Peter P Waskiewicz Jr wrote:
> >@@ -3345,6 +3358,7 @@ void free_netdev(struct net_device *dev)  {  
> >#ifdef CONFIG_SYSFS
> > 	/*  Compatibility with error handling in drivers */
> >+	kfree((char *)dev->egress_subqueue);
> > 	if (dev->reg_state == NETREG_UNINITIALIZED) {
> > 		kfree((char *)dev - dev->padded);
> > 		return;
> >@@ -3356,6 +3370,7 @@ void free_netdev(struct net_device *dev)
> > 	/* will free via device release */
> > 	put_device(&dev->dev);
> > #else
> >+	kfree((char *)dev->egress_subqueue);
> > 	kfree((char *)dev - dev->padded);
> > #endif
> > }
> 
> Ahem. Explain that cast.

Jan,
	This can be removed if needed; however, I'm just copying what
the other kfree()'s are doing in this function.  Any instance of a
typecast that I introduced in these patches are just following what
others have done in that section of the code.  So the cast is just for
consistency in this particular area.  If you'd like me to remove it, I
can do that.

Thanks,

-PJ Waskiewicz
