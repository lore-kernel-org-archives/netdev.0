From: Sonny Rao <sonnyrao@us.ibm.com>
Subject: Re: [PATCH] Add missing memory barriers to clean_rx_irq functions
 in Intel Drivers
Date: Tue, 27 Jul 2010 17:46:31 -0500
Message-ID: <20100727224631.GO17248@us.ibm.com>
References: <20100727223452.GM17248@us.ibm.com>
 <AANLkTiniyOsNifzP47qR_zhq993U8p5wj1iJ+v4jzZkX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sf.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:38467 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab0G0WpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 18:45:23 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6RMcFqS023350
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 16:38:15 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6RMjCKT119330
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 16:45:12 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6RMjAmA006408
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 16:45:11 -0600
Content-Disposition: inline
In-Reply-To: <AANLkTiniyOsNifzP47qR_zhq993U8p5wj1iJ+v4jzZkX@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 03:41:46PM -0700, Jeff Kirsher wrote:
> On Tue, Jul 27, 2010 at 15:34, Sonny Rao <sonnyrao@us.ibm.com> wrote:
> > This patch is similar to what was fixed in ixgbe in this patch:
> >
> > http://marc.info/?l=3De1000-devel&m=3D126593062701537&w=3D3
> >
> > We should add read memory barriers to all the similar cases across =
the
> > Intel ethernet driver family. =A0In the case of ixgbevf I've also a=
dded
> > a missing barrier to the clean_tx_irq path because I missed it in m=
y
> > last patch.
> >
> > Without the barrier a processor can speculate a load ahead of the l=
oad
> > which looks at the status bit and get stale information causing a
> > number of different issues including invalid packet length, NULL
> > pointers, or bad data since checksumming was assumed to be done
> > in hardware.
> >
> > Signed-off-by: Milton Miller <miltonm@bga.com>
> > Signed-off-by: Sonny Rao <sonnyrao@us.ibm.com>
> > cc: stable <stable@kernel.org>
> >
>=20
> I already have a similar patch in my queue from you Sonny, although I
> see that this patch has made a few more changes.  Is this version 2?

Well, the previous one was for the clean_tx_irq functions this one is=20
for the clean_rx_irq functions.  I'd gotten the two confused when I
referenced Anton's original patch -- which was also a clean_rx_irq
patch.  So they are touching different code paths but fixing similar
problems.


--=20
Sonny Rao, LTC OzLabs, BML team
