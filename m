From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 17:31:43 -0700
Message-ID: <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com>
References: <1181253445.4071.4.camel@localhost>
	 <20070607.154421.109060486.davem@davemloft.net>
	 <1181256848.4071.57.camel@localhost>
	 <20070607.160035.00774597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, auke-jan.h.kok@intel.com, jeff@garzik.org,
	kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:47043 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966733AbXFHAbs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 20:31:48 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l580Vlii009660
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 20:31:47 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l580VlR5549658
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 20:31:47 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l580Vjrx004263
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 20:31:47 -0400
In-Reply-To: <20070607.160035.00774597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-06-07 at 16:00 -0700, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Thu, 07 Jun 2007 18:54:08 -0400
> 
> > On Thu, 2007-07-06 at 15:44 -0700, David Miller wrote:
> > > From: jamal <hadi@cyberus.ca>
> > > Date: Thu, 07 Jun 2007 17:57:25 -0400
> > > 
> > > > I empathize but take a closer look; seems mostly useless.
> > > 
> > > I thought E1000 still uses LLTX, and if so then multiple cpus can most
> > > definitely get into the ->hard_start_xmit() in parallel.
> > 
> > AFAICS, only one CPU can dequeue from the qdisc i.e s/he who holds
> > __LINK_STATE_QDISC_RUNNING is the only one who can call qdisc_restart
> > and only s/he can enter ->hard_start_xmit().
> > 
> > Am i missing something?
> 
> That's right we fixed that the other week.

If the QDISC_RUNNING flag guarantees that only one CPU can call
dev->hard_start_xmit(), then why do we need to hold netif_tx_lock
for non-LLTX drivers?

Thanks
Sridhar

