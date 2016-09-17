From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net PATCH] mlx4: fix XDP_TX is acting like XDP_PASS on TX ring
 full
Date: Sat, 17 Sep 2016 16:46:50 +0200
Message-ID: <20160917164650.53e68314@redhat.com>
References: <20160916203535.20016.45146.stgit@firesoul>
        <20160916204350.GA20076@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, tariqt@mellanox.com,
        Eric Dumazet <eric.dumazet@gmail.com>, tom@herbertland.com,
        rana.shahot@gmail.com, "David S. Miller" <davem@davemloft.net>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55108 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751401AbcIQOq4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 10:46:56 -0400
In-Reply-To: <20160916204350.GA20076@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Sep 2016 13:43:50 -0700
Brenden Blanco <bblanco@plumgrid.com> wrote:

> On Fri, Sep 16, 2016 at 10:36:12PM +0200, Jesper Dangaard Brouer wrote:
> > The XDP_TX action can fail transmitting the frame in case the TX ring
> > is full or port is down.  In case of TX failure it should drop the
> > frame, and not as now call 'break' which is the same as XDP_PASS.
> > 
> > Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>  
> 
> You could in theory have also tried to recycle the page instead of
> dropping it, but that's probably not worth optimizing when tx is backed
> up, as you'll only save a handful of page_put's. The code to do so
> wouldn't have been pretty.

Yes, we could (and perhaps should) recycle the page instead. But as you
also mention it would not look pretty. I'll send a V3, as XDPs primary
concern is performance.

> Reviewed-by: Brenden Blanco <bblanco@plumgrid.com>



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
