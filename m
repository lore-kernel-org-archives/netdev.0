From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 0/3] mvneta: software TSO implementation
Date: Fri, 11 Apr 2014 07:48:47 +0200
Message-ID: <20140411054847.GE30855@1wt.eu>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com> <20140410.205128.1312451576920196881.davem@davemloft.net> <1397178150.16584.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	ezequiel.garcia@free-electrons.com, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	tawfik@marvell.com, alior@marvell.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:3977 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754589AbaDKFsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 01:48:55 -0400
Content-Disposition: inline
In-Reply-To: <1397178150.16584.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 10, 2014 at 06:02:30PM -0700, Eric Dumazet wrote:
> On Thu, 2014-04-10 at 20:51 -0400, David Miller wrote:
> > This is not really driver specific code.
> > 
> > Please create an appropriate abstraction, and put this code in a
> > common place so that any driver can do this.
> > 
> > Thanks.
> 
> Note a prior implementation existed in
> 
> drivers/net/ethernet/tile/tilegx.c
> 
> Note sure how it can be properly factorized, but worth trying .

I also tried to find how to do this for mv643xx_eth a few years ago
based on other drivers (eg: tilegx) and failed to find anything
common. At this level, we're really playing with the NIC's descriptors,
and many of them have different capabilities (eg: HW checksums for all
frames, VLAN or none, etc...). I don't really see how this could be
factorized, and since many NICs do support TSO, I'm not convinced by
the effort.

Willy
