From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] macvtap: unbreak receiving of gro skb with frag list
Date: Tue, 27 Oct 2015 11:05:50 +0200
Message-ID: <20151027110253-mutt-send-email-mst@redhat.com>
References: <1445576225-27710-1-git-send-email-jasowang@redhat.com>
 <20151023163659-mutt-send-email-mst@redhat.com>
 <562D9AED.4060607@redhat.com>
 <20151026080851-mutt-send-email-mst@redhat.com>
 <562DCDF2.6030305@redhat.com>
 <20151026102928-mutt-send-email-mst@redhat.com>
 <562EE851.40605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <562EE851.40605@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 27, 2015 at 10:58:25AM +0800, Jason Wang wrote:
> 
> 
> On 10/26/2015 04:30 PM, Michael S. Tsirkin wrote:
> > On Mon, Oct 26, 2015 at 02:53:38PM +0800, Jason Wang wrote:
> >>
> >> On 10/26/2015 02:09 PM, Michael S. Tsirkin wrote:
> >>> On Mon, Oct 26, 2015 at 11:15:57AM +0800, Jason Wang wrote:
> >>>> On 10/23/2015 09:37 PM, Michael S. Tsirkin wrote:
> >>>>> On Fri, Oct 23, 2015 at 12:57:05AM -0400, Jason Wang wrote:
> >>>>>> We don't have fraglist support in TAP_FEATURES. This will lead
> >>>>>> software segmentation of gro skb with frag list. Fixes by having
> >>>>>> frag list support in TAP_FEATURES.
> >>>>>>
> >>>>>> With this patch single session of netperf receiving were restored from
> >>>>>> about 5Gb/s to about 12Gb/s on mlx4.
> >>>>>>
> >>>>>> Fixes a567dd6252 ("macvtap: simplify usage of tap_features")
> >>>>>> Cc: Vlad Yasevich <vyasevic@redhat.com>
> >>>>>> Cc: Michael S. Tsirkin <mst@redhat.com>
> >>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> >>>>> Thanks!
> >>>>> Does this mean we should look at re-adding NETIF_F_FRAGLIST
> >>>>> to virtio-net as well?
> >>>> Not sure I get the point, but probably not. This is for receiving and
> >>>> skb_copy_datagram_iter() can deal with frag list.
> >>> Point is:
> >>> - bridge within guest
> >>> - assigned device creating gro skbs with frag list bridged to virtio
> >> I see, but this problem looks not specific to virtio. Most cards does
> >> not support frag list.
> > These will be slower when used with a bridge then, won't they?
> 
> For forwarding, not sure. GRO has latency and cpu overhead anyway.

Right but that's up to the user. You aren't disabling GRO
on source, you are just splitting it up.

> Anyway I can try to add the support for this.

Which reminds me: on modern devices there are commands to control
offloads, so for these, we should support turning offloads on/off using
ethtool.

-- 
MST
