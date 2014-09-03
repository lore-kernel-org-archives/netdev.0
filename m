From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] qdisc: validate frames going through the
 direct_xmit path
Date: Wed, 3 Sep 2014 15:52:13 +0200
Message-ID: <20140903155213.62ff4eff@redhat.com>
References: <20140902225548.885.79277.stgit@ahduyck-bv4.jf.intel.com>
	<20140903114841.19969.22671.stgit@dragon>
	<1409751805.26422.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11620 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932414AbaICNwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 09:52:20 -0400
In-Reply-To: <1409751805.26422.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 03 Sep 2014 06:43:25 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2014-09-03 at 13:48 +0200, Jesper Dangaard Brouer wrote:
> > In commit 50cbe9ab5f8d ("net: Validate xmit SKBs right when we pull them
> > out of the qdisc") the validation code was moved out of dev_hard_start_xmit
> > and into dequeue_skb. However this overlooked the fact that we do not
> > always enqueue the skb onto a qdisc, if qdisc have flag TCQ_F_CAN_BYPASS.
> > 
> > As a result Alex was seeing issues trying to connect to a vhost_net interface
> > after this patch was applied.
> > 
> > Added a call to validate_xmit_skb in __dev_xmit_skb(), in the code path
> > for qdiscs with TCQ_F_CAN_BYPASS flag.
> > 
> > Fixes:  50cbe9ab5f8d ("net: Validate xmit SKBs right when we pull them out of the qdisc")
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> 
> Jesper, you missed another spot, when there is no qdisc on the device.
> 
> __dev_queue_xmit() calls dev_hard_start_xmit() around line 2886
> 
> Could we try to not add a myriad of small patches ?
> 
> Some of us will need to backport all of them.

I'm in the same backport situation ;-)

I'll send a V2 of this patch, with missed spot...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
