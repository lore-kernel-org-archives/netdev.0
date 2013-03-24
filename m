From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sun, 24 Mar 2013 18:23:04 +0100
Message-ID: <20130324172304.GB12968@order.stressinduktion.org>
References: <20130324014125.GB17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7C79@nasanexd02f.na.qualcomm.com> <20130324034037.GC17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CA8@nasanexd02f.na.qualcomm.com> <20130324043738.GD17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CCD@nasanexd02f.na.qualcomm.com> <20130324051325.GE17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CFC@nasanexd02f.na.qualcomm.com> <20130324052300.GA12968@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7D1E@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55175 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754112Ab3CXRXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 13:23:06 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C4542856489E7D1E@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 05:42:41AM +0000, Huang, Xiong wrote:
> > > >
> > > > The caputered packets show that a 16 byte segment overwrites later
> > > > data in the same packet, sometimes even multiple contiguous 16 byte
> > segments.
> > > >
> > > > The corrupted packets look like this:
> > > >
> > > > ...ABC....DBBEF..
> > > >
> > > > Each character represents a 16 byte region, the dots are dont-care
> > > > placeholders. The BB-region is overwritten by the data of the first B-
> > region.
> > > >
> > >
> > > It looks like a DMA issue. Not checksum related. :(
> > 
> > Yes, I think so, too. Until this is resolved I would propose to not set
> > CHECKSUM_UNNECESSARY because it could corrupt data (like for the original
> > poster).
> > 
> > Do you have any idea where how these errors could be resolved? I e.g. could
> > not reproduce it with FreeBSD and the driver seems to be related to the linux
> > driver.
> 
> 1.  pages cross 4GB bouandary ?  or overlap with each other ?

This should not be the case.

> 2. try to set hw->dmaw_block = atl1e_dma_req_128 

Sorry, we can still reproduce corrupted frames with this change.

> 3. can you print reg15C0 content when the NIC is in normal tx/rx status ?

Yes, dma register is reg15C0 == 0x247c24 all the time (vanilla kernel without
any of your proposed changes).

Couldn't this also be because of a timing issue? It does take much more time
on slower machines(eeepc) to reproduce this issue. On a normal desktop machine it
does nearly occur instantaneous.

Thanks,

  Hannes
