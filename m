From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] macvtap/macvlan: use IFF_NO_QUEUE
Date: Thu, 27 Aug 2015 13:43:39 +0300
Message-ID: <20150827134102-mutt-send-email-mst@redhat.com>
References: <1440405192-25926-1-git-send-email-jasowang@redhat.com>
 <20150825131608-mutt-send-email-mst@redhat.com>
 <55DC51C1.5090201@redhat.com>
 <55DC98A3.7010601@redhat.com>
 <55DD527A.8040806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55DD527A.8040806@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 26, 2015 at 01:45:30PM +0800, Jason Wang wrote:
> 
> 
> On 08/26/2015 12:32 AM, Vlad Yasevich wrote:
> > On 08/25/2015 07:30 AM, Jason Wang wrote:
> >>
> >> On 08/25/2015 06:17 PM, Michael S. Tsirkin wrote:
> >>> On Mon, Aug 24, 2015 at 04:33:12PM +0800, Jason Wang wrote:
> >>>>> For macvlan, switch to use IFF_NO_QUEUE instead of tx_queue_len = 0.
> >>>>>
> >>>>> For macvtap, after commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523
> >>>>> ("macvtap: Add support of packet capture on macvtap
> >>>>> device."). Multiqueue macvtap suffers from single qdisc lock
> >>>>> contention. This is because macvtap claims a non zero tx_queue_len and
> >>>>> it reuses this value as it socket receive queue size.Thanks to
> >>>>> IFF_NO_QUEUE, we can remove the lock contention without breaking
> >>>>> existing socket receive queue length logic.
> >>>>>
> >>>>> Cc: Patrick McHardy <kaber@trash.net>
> >>>>> Cc: Vladislav Yasevich <vyasevic@redhat.com>
> >>>>> Cc: Michael S. Tsirkin <mst@redhat.com>
> >>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> >>> Seems to make sense. Give me a day or two to get over the jet lag
> >>> (and get out from under the pile of mail accumulated while I was traveling),
> >>> I'll review properly and ack.
> >>>
> >> A note on this patch: only default qdisc were removed but we don't lose
> >> the ability to attach a qdisc to macvtap (though it may cause lock
> >> contention on multiqueue case).
> >>
> > Wouldn't that lock contention be solved if we really had multiple queues
> > for multi-queue macvtaps?
> >
> > -vlad
> 
> Yes, but this introduce another layer of txq locks contention?

I don't follow - why does it? Could you clarify please?

> And it
> also needs macvlan multiqueue support. We used to do something like this
> but switch to NETIF_F_LLTX finally. You may refer:
> 
> 2c11455321f37da6fe6cc36353149f9ac9183334 macvlan: add multiqueue capability
> 8ffab51b3dfc54876f145f15b351c41f3f703195 macvlan: lockless tx path

My concern is that the moment someone configures a non-standard qdisc
scalability suddenly disappears. That would also be tricky to debug in the
field as not a lot of developers use non-standard qdiscs.
What do you think?

-- 
MST
