From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: switch to use build_skb() for small
 buffer
Date: Wed, 22 Feb 2017 05:06:34 +0200
Message-ID: <20170222050601-mutt-send-email-mst@kernel.org>
References: <1487666788-9658-1-git-send-email-jasowang@redhat.com>
 <20170221162849-mutt-send-email-mst@kernel.org>
 <35244d06-2d0d-3f2e-0cd1-43137988c869@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <35244d06-2d0d-3f2e-0cd1-43137988c869@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2017 at 10:58:08AM +0800, Jason Wang wrote:
> 
> 
> On 2017年02月21日 22:37, Michael S. Tsirkin wrote:
> > On Tue, Feb 21, 2017 at 04:46:28PM +0800, Jason Wang wrote:
> > > This patch switch to use build_skb() for small buffer which can have
> > > better performance for both TCP and XDP (since we can work at page
> > > before skb creation). It also remove lots of XDP codes since both
> > > mergeable and small buffer use page frag during refill now.
> > > 
> > >                         Before   | After
> > > XDP_DROP(xdp1) 64B  :  11.1Mpps | 14.4Mpps
> > > 
> > > Tested with xdp1/xdp2/xdp_ip_tx_tunnel and netperf.
> > > 
> > > Signed-off-by: Jason Wang<jasowang@redhat.com>
> > Thanks!
> > I had a similar patch for mergeable too, though it's trickier there
> > as host has a lot of flexibility in sizing buffers.
> > Looks like a good intermediate step to me.
> 
> Yes, I think it's more tricky for the case of mergeable buffer:
> 
> 1) we need reserve NET_SKB_PAD + NET_IP_ALIGN for each buffer, this will
> break rx frag coalescing
> 2) need tailroom for skb_shinfo, so it won't work for all size of packet
> 
> Thanks

Have you seen my prototype? It works with qemu in practice,
just needs to cover a bunch of corner cases.


> > 
> > 
> > Acked-by: Michael S. Tsirkin<mst@redhat.com>
> > 
