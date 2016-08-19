From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] gianfar: prevent fragmentation in DSA environments
Date: Fri, 19 Aug 2016 19:05:03 +0200
Message-ID: <20160819170503.GA14068@lunn.ch>
References: <1471598174-16938-1-git-send-email-zefir.kurtisi@neratec.com>
 <20160819145900.GD7343@lunn.ch>
 <c1cda2ea-21e8-0265-e1c3-687f2396a7f1@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39251 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754555AbcHSRYr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 13:24:47 -0400
Content-Disposition: inline
In-Reply-To: <c1cda2ea-21e8-0265-e1c3-687f2396a7f1@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't fully understand why GFAR_RXB_SIZE has to be lower than
> that, preventing the HW using all available memory - the freescale
> guys most probably do.

That will be because the cache invalidates in the DMA API are
expensive. There is no point invalidating the whole 2K if you never
make use of the top part. Just invalidate what is actually used.  I
optimised the Intel i210 driver recently along these lines, and my
receive performance went up 6%

     Andrew
