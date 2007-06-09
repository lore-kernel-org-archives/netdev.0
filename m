From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Fri, 08 Jun 2007 20:24:31 -0400
Message-ID: <1181348671.4056.14.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902FFCE03@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>, kaber@trash.net,
	netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.226]:8552 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938AbXFIAYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 20:24:36 -0400
Received: by qb-out-0506.google.com with SMTP id z8so1169816qbc
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2007 17:24:35 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902FFCE03@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-06 at 12:55 -0700, Waskiewicz Jr, Peter P wrote:
> > I thought the correct use is to get this lock on clean_tx 
> > side which can get called on a different cpu on rx (which 
> > also cleans up slots for skbs that have finished xmit). Both 
> > TX and clean_tx uses the same tx_ring's head/tail ptrs and 
> > should be exclusive. But I don't find clean tx using this 
> > lock in the code, so I am confused :-)
> 
> >From e1000_main.c, e1000_clean():
> 
>         /* e1000_clean is called per-cpu.  This lock protects
>          * tx_ring[0] from being cleaned by multiple cpus
>          * simultaneously.  A failure obtaining the lock means
>          * tx_ring[0] is currently being cleaned anyway. */
>         if (spin_trylock(&adapter->tx_queue_lock)) {
>                 tx_cleaned = e1000_clean_tx_irq(adapter,
>                                                 &adapter->tx_ring[0]);
>                 spin_unlock(&adapter->tx_queue_lock);
>         }

Are you saying theres no problem because the adapter->tx_queue_lock is
being held? 

> In a multi-ring implementation of the driver, this is wrapped with for
> (i = 0; i < adapter->num_tx_queues; i++) and &adapter->tx_ring[i].  This
> lock also prevents the clean routine from stomping on xmit_frame() when
> transmitting.  Also in the multi-ring implementation, the tx_lock is
> pushed down into the individual tx_ring struct, not at the adapter
> level.

That sounds right - but the adapter lock is not related to tx_lock in
current e1000, correct?

cheers,
jamal


