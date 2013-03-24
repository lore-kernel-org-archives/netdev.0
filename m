From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sun, 24 Mar 2013 06:23:00 +0100
Message-ID: <20130324052300.GA12968@order.stressinduktion.org>
References: <20130324012625.GA17948@order.stressinduktion.org> <89joa2largv8@mids.svenhartge.de> <20130324014125.GB17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7C79@nasanexd02f.na.qualcomm.com> <20130324034037.GC17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CA8@nasanexd02f.na.qualcomm.com> <20130324043738.GD17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CCD@nasanexd02f.na.qualcomm.com> <20130324051325.GE17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CFC@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54440 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386Ab3CXFXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 01:23:02 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C4542856489E7CFC@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 05:16:03AM +0000, Huang, Xiong wrote:
> > > >
> > > > Btw the captured corrupted packets are ordinary non-fragmented TCP
> > > > IPv4 packets. But perhaps these flags are dual-use?
> > > >
> > > Not dual-use.  You could check  flags for corrupted packets and compare it
> > with good packet.
> > > Your corrupted packet is just TCP checksum error ?
> > 
> > I'll try it.
> > 
> > The caputered packets show that a 16 byte segment overwrites later data in
> > the same packet, sometimes even multiple contiguous 16 byte segments.
> > 
> > The corrupted packets look like this:
> > 
> > ...ABC....DBBEF..
> > 
> > Each character represents a 16 byte region, the dots are dont-care
> > placeholders. The BB-region is overwritten by the data of the first B-region.
> > 
> 
> It looks like a DMA issue. Not checksum related. :(

Yes, I think so, too. Until this is resolved I would propose to not set
CHECKSUM_UNNECESSARY because it could corrupt data (like for the original
poster).

Do you have any idea where how these errors could be resolved? I e.g. could
not reproduce it with FreeBSD and the driver seems to be related to the linux
driver.
