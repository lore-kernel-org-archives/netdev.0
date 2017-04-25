From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Blogpost evaluation this [PATCH v4 net-next RFC] net: Generic XDP
Date: Tue, 25 Apr 2017 13:25:49 -0400
Message-ID: <20170425172549.GQ4730@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170413.120925.2082322246776478766.davem@davemloft.net>
 <20170424162405.1183f2e7@redhat.com>
 <20170424.182643.485613135674690555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brouer@redhat.com, xdp-newbies@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34683 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951992AbdDYRZx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:25:53 -0400
Received: by mail-qk0-f193.google.com with SMTP id u75so9722154qka.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:25:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170424.182643.485613135674690555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 06:26:43PM -0400, David Miller wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Mon, 24 Apr 2017 16:24:05 +0200
> 
> > I've done a very detailed evaluation of this patch, and I've created a
> > blogpost like report here:
> > 
> >  https://prototype-kernel.readthedocs.io/en/latest/blogposts/xdp25_eval_generic_xdp_tx.html
> 
> Thanks for doing this Jesper.

Yes, this is excellent.  I'm not all the way thru it, but I looked at
the data and corroborate the results you are seeing.

My results for both optimized and generic XDP for
xdp_bench01_mem_access_cost --action XDP_DROP --readmem are quite
similar to yours (11.7Mpps and 7.8Mpps, respectively for me 11.7Mpps and
8.4Mpps for you).

I also noted (as you did) that there is no discernible difference
running xdp_bench01_mem_access_cost with or without the --readmem
option since the packet data is already being accessed that late it the
stack.

> 
> > I didn't evaluate the adjust_head part, so I hope Andy is still
> > planning to validate that part?
> 
> I was hoping he would post some results today as well.
> 
> Andy, how goes it? :)

Sorry for the delayed response.  I was AFK yesterday, but based on
testing from Friday and what I wrapped up today all looks good to me.

On my system (i7-6700 CPU @ 3.40GHz) the reported and actual TX
throughput for xdp_tx_iptunnel is 4.6Mpps for the optimized XDP.

For generic XDP the reported throughput of xdp_tx_iptunnel is 4.6Mpps
but only ~880kpps actually on the wire.  It seems to me that can be
fixed with a follow-up for offending drivers or the stack if deemed that
there is a real error there.

> Once the basic patch is ready and integrated in we can try to do
> xmit_more in generic XDP and see what that does for XDP_TX
> performance.

Agreed.
