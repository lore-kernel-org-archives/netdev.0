From: David Miller <davem@davemloft.net>
Subject: Re: smp_affinity, MSI-X and 2.6.21.1
Date: Wed, 09 May 2007 02:46:14 -0700 (PDT)
Message-ID: <20070509.024614.48396047.davem@davemloft.net>
References: <463F91D3.3010000@hp.com>
	<p733b26waha.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40498
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755560AbXEIJqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 05:46:13 -0400
In-Reply-To: <p733b26waha.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: 09 May 2007 12:35:29 +0200

> Rick Jones <rick.jones2@hp.com> writes:
> 
> > Folks -
> > 
> > Is it a bug, or a feature that after changing a device's smp_affinity
> > via echo "N" >> /proc/irq/M/smp_affinity that the new mask isn't
> > visible via cat /proc/irq/M/smp_affinity until after actual interrupts
> > are taken?
> 
> Intel chipsets can only safely update affinity during interrupt processing.
> You see a side effect of the code implementing this restriction.

That's true, but we are talking about software state so in some sense
it might be better that the affinity-to-be is reported to the user in
this case.

Delayed register updates are an implementation detail the user does
not need to know about here.
