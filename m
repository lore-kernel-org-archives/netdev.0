From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/8] ibm_newemac: Fix possible lockup on close
Date: Wed, 21 Nov 2007 09:43:50 -0600
Message-ID: <20071121094350.44a18e26@weaponx>
References: <1195625198.76200.922309668615.qpush@grosgo>
	<20071121060729.71A1FDDE01@ozlabs.org>
	<20071121154123.GB23589@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:50790 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051AbXKUPoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 10:44:00 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lALEgo4P007173
	for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 09:42:50 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lALFhq7b091796
	for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 08:43:52 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lALFhpno013990
	for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 08:43:52 -0700
In-Reply-To: <20071121154123.GB23589@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Nov 2007 16:41:23 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Wed, Nov 21, 2007 at 05:06:39PM +1100, Benjamin Herrenschmidt wrote:
> > It's a bad idea to call flush_scheduled_work from within a
> > netdev->stop because the linkwatch will occasionally take the
> > rtnl lock from a workqueue context, and thus that can deadlock.
> > 
> > This reworks things a bit in that area to avoid the problem.
> 
> So from the name of the driver you want to keep the previous emac
> driver around.  Is there a good reason for that?

It's being kept around until arch/ppc dies.  Then things should get
renamed.

josh
