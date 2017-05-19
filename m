From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 9/9] nfp: eliminate an if statement in
 calculation of completed frames
Date: Fri, 19 May 2017 09:18:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFFA91C@AcuExch.aculab.com>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
        <20170516005523.26124-10-jakub.kicinski@netronome.com>
        <063D6719AE5E284EB5DD2968C1650D6DCFFF7B93@AcuExch.aculab.com>
 <20170517103637.2dd8b49d@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: 'Jakub Kicinski' <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:54722 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753073AbdESJSi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 05:18:38 -0400
In-Reply-To: <20170517103637.2dd8b49d@cakuba.netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski
> Sent: 17 May 2017 18:37
..
> > >  	while (todo--) {
> > >  		idx = D_IDX(tx_ring, tx_ring->rd_p++);
> >
> > That '++' looks suspicious.
> > I think you need to decide whether you are incrementing pointers into the ring
> > or indexes into it.
> > Sometimes it is safer to use a non-wrapping index and mask when accessing the entry.
> > 	entry_ptr = &ring[idx & (RING_SIZE - 1)]
> > Ring full is then (read_idx == write_idx + RING_SIZE),
> > ring empty (read_idx == write_idx).
> > So the index just wrap at (probably)_2^32.
> 
> I may be missing the point.  I use a mix of the two, actually, the
> software pointers are free running (non-wrapping) but the HW QCP
> pointers wrap.  Because HW pointers wrap I always keep one entry on
> the rings empty, see nfp_net_tx_full().

Ah, I'd assumed that rd_p was a pointer, not an index.

	David
