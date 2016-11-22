From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v2 4/5] virtio_net: add dedicated XDP transmit
 queues
Date: Tue, 22 Nov 2016 16:59:31 +0200
Message-ID: <20161122165852-mutt-send-email-mst@kernel.org>
References: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
 <20161120025104.19187.54400.stgit@john-Precision-Tower-5810>
 <20161121234008-mutt-send-email-mst@kernel.org>
 <5833FF24.2010800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, kubakici@wp.pl,
        shm@cumulusnetworks.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37746 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753255AbcKVO7e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 09:59:34 -0500
Content-Disposition: inline
In-Reply-To: <5833FF24.2010800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 12:17:40AM -0800, John Fastabend wrote:
> On 16-11-21 03:13 PM, Michael S. Tsirkin wrote:
> > On Sat, Nov 19, 2016 at 06:51:04PM -0800, John Fastabend wrote:
> >> XDP requires using isolated transmit queues to avoid interference
> >> with normal networking stack (BQL, NETDEV_TX_BUSY, etc). This patch
> >> adds a XDP queue per cpu when a XDP program is loaded and does not
> >> expose the queues to the OS via the normal API call to
> >> netif_set_real_num_tx_queues(). This way the stack will never push
> >> an skb to these queues.
> >>
> >> However virtio/vhost/qemu implementation only allows for creating
> >> TX/RX queue pairs at this time so creating only TX queues was not
> >> possible. And because the associated RX queues are being created I
> >> went ahead and exposed these to the stack and let the backend use
> >> them. This creates more RX queues visible to the network stack than
> >> TX queues which is worth mentioning but does not cause any issues as
> >> far as I can tell.
> >>
> >> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > 
> > FYI what's supposed to happen is packets from the same
> > flow going in the reverse direction will go on the
> > same queue.
> > 
> > This might come in handy when implementing RX XDP.
> > 
> 
> Yeah but if its the first packet not part of a flow then presumably it
> can pick any queue but its worth keeping in mind certainly.
> 
> .John

Oh I agree, absolutely. This was just a FYI in case it comes useful
as an optimization down the road.

-- 
MST
