From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] S390: Fix libphy link failure
Date: Mon, 6 May 2013 17:49:31 +0200
Message-ID: <20130506154931.GA8453@osiris>
References: <1367852019.4569.123.camel@chaos.site>
 <20130506.110011.1813294677998011362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jdelvare@suse.de, netdev@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Sebastian Ott <sebott@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:48046 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830Ab3EFPth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 11:49:37 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Mon, 6 May 2013 16:46:37 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3F91217D801B
	for <netdev@vger.kernel.org>; Mon,  6 May 2013 16:50:36 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r46FnMql57999502
	for <netdev@vger.kernel.org>; Mon, 6 May 2013 15:49:22 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r46FnVp9016305
	for <netdev@vger.kernel.org>; Mon, 6 May 2013 09:49:32 -0600
Content-Disposition: inline
In-Reply-To: <20130506.110011.1813294677998011362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 06, 2013 at 11:00:11AM -0400, David Miller wrote:
> From: Jean Delvare <jdelvare@suse.de>
> Date: Mon, 06 May 2013 16:53:39 +0200
> 
> > On S390 basic IRQ functions are provided by the PCI subsystem, so
> > code which calls these cannot be built if PCI support was not
> > selected.
> > 
> > Signed-off-by: Jean Delvare <jdelvare@suse.de>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > ---
> > I know this isn't nice, but in the current state of S390 support
> > this is all I can offer.
> 
> I really am tired of all of these special S390 dependencies.
> 
> You can't say this is a new problem, because we've been hitting this
> issue repeatedly for more than a decade.  And I don't want to hear any
> excuses, we've all already invested enough time into this to prove
> that catering to S390's weird build limitations is a never ending
> burdon for non-s390 people.

Agreed. And you won't hear any excuses since I'm tired of adding these
Kconfig dependencies as well.
Unfortunately it got worse instead of better since we support CONFIG_PCI.

> Really, our interfaces are abstract enough that every driver ought to
> be buildable on every architecture.
> 
> It's time to put the burdon on your side, if you don't support some
> IRQ interface or whatever, provide a stub that returns an error
> rather than being that "special architecture" that everything else
> has to specially cater for with ugly Kconfig dependencies.

Actually I'm in favor of supplying some stupid IRQ stubs as well.
Unless our PCI guys think that we can go for GENERIC_HARDIRQS.
But that will only work for 64 bit configs, not 31 bit.

So you wouldn't mind some stupid stubs like

request_irq(unsigned int irq, irq_handler_t handler, unsigned long flags,
            const char *name, void *dev) {
	    return -EWHATEVER;
}

?
