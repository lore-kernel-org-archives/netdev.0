From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 0/3] mvneta: software TSO implementation
Date: Fri, 11 Apr 2014 08:30:21 +0200
Message-ID: <20140411063021.GH30855@1wt.eu>
References: <20140410.205128.1312451576920196881.davem@davemloft.net> <1397178150.16584.53.camel@edumazet-glaptop2.roam.corp.google.com> <20140411054847.GE30855@1wt.eu> <20140411.022006.1718259701974368498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, ezequiel.garcia@free-electrons.com,
	netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	tawfik@marvell.com, alior@marvell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4001 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751AbaDKGab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 02:30:31 -0400
Content-Disposition: inline
In-Reply-To: <20140411.022006.1718259701974368498.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2014 at 02:20:06AM -0400, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Fri, 11 Apr 2014 07:48:47 +0200
> 
> > I also tried to find how to do this for mv643xx_eth a few years ago
> > based on other drivers (eg: tilegx) and failed to find anything
> > common. At this level, we're really playing with the NIC's descriptors,
> > and many of them have different capabilities (eg: HW checksums for all
> > frames, VLAN or none, etc...). I don't really see how this could be
> > factorized, and since many NICs do support TSO, I'm not convinced by
> > the effort.
> 
> I wanted to hook this into the NIU driver as well, which also lacks
> TSO support.
> 
> The descriptor and checksum part is chip specific, but the segmentation
> of the buffer segments, calculating the number of necessary descriptors,
> etc. absolutely is not.

Agreed.

> Please work on finding a suitable abstraction, it's possible.

Do you think for example that having an xmit_tso() function which would
iterate over all segments and call something like :
   ->build_hdr()
   ->build_data()
   ->unroll_all()

would be sufficient ?

I fear that relying on function pointers in the inner loop can
significantly offset the CPU savings, but it could be attempted.

I think that the fact you want to do it for NIU is a good opportunity
to try to do it the right way in the most generic mode, but we'll
surely need your help on this!

Willy
