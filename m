From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v2] net: add PCINet driver
Date: Wed, 5 Nov 2008 11:18:41 -0800
Message-ID: <20081105191841.GB31188@ovro.caltech.edu>
References: <20081029202027.GH12879@ovro.caltech.edu> <200811042123.03819.arnd@arndb.de> <20081104222927.GE4641@ovro.caltech.edu> <200811051419.53194.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:41974 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbYKETSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 14:18:43 -0500
Content-Disposition: inline
In-Reply-To: <200811051419.53194.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2008 at 02:19:52PM +0100, Arnd Bergmann wrote:
> On Tuesday 04 November 2008, Ira Snyder wrote:
> 
> > So, since interrupts are disabled while my interrupt handler is running,
> > I think I should be able to use spin_lock() and spin_unlock(), correct?
> 
> yes.
> 
> > But sparse gives me the following warning:
> > wqt.c:185:9: warning: context imbalance in 'wqt_interrupt': wrong count at exit
> > wqt.c:185:9:    context 'lock': wanted 0, got 1
> > 
> > If I'm using spin_lock_irqsave() and spin_lock_irqrestore() I do not get
> > the same warnings. Therefore I must have some misunderstanding :)
> 
> 
> I've seen something like that before, I think it was a bug either in
> sparse or in the powerpc platform code. Try updating both the kernel
> and sparse and see if it still happens.
> 

Ok, I had the latest sparse, but I've been developing the host driver
against Ubuntu 8.04's kernel, which is based on 2.6.24. Using Linus' git
tree resolved the errors from sparse.

I ended up finding that the dma_mapping_error() API has changed, and so
I updated the driver for that. It should build against 2.6.28-rc now.
I'll post it in a little while.

Ira
