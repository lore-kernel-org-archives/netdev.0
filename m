From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [net PATCH] mlx4: fix XDP_TX is acting like XDP_PASS on TX ring
 full
Date: Fri, 16 Sep 2016 13:43:50 -0700
Message-ID: <20160916204350.GA20076@gmail.com>
References: <20160916203535.20016.45146.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tariqt@mellanox.com,
        Eric Dumazet <eric.dumazet@gmail.com>, tom@herbertland.com,
        rana.shahot@gmail.com, "David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35321 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965379AbcIPUnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 16:43:53 -0400
Received: by mail-pa0-f54.google.com with SMTP id oz2so24574234pac.2
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 13:43:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160916203535.20016.45146.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 10:36:12PM +0200, Jesper Dangaard Brouer wrote:
> The XDP_TX action can fail transmitting the frame in case the TX ring
> is full or port is down.  In case of TX failure it should drop the
> frame, and not as now call 'break' which is the same as XDP_PASS.
> 
> Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

You could in theory have also tried to recycle the page instead of
dropping it, but that's probably not worth optimizing when tx is backed
up, as you'll only save a handful of page_put's. The code to do so
wouldn't have been pretty.

Reviewed-by: Brenden Blanco <bblanco@plumgrid.com>
