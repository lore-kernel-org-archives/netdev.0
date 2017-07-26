From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] Revert "vhost: cache used event for better
 performance"
Date: Wed, 26 Jul 2017 18:21:56 +0300
Message-ID: <20170726162557-mutt-send-email-mst@kernel.org>
References: <1501056197-3368-1-git-send-email-jasowang@redhat.com>
 <20170726155435-mutt-send-email-mst@kernel.org>
 <117542fc-eef9-c043-7c9e-daafceb7db4e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <117542fc-eef9-c043-7c9e-daafceb7db4e@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2017 at 09:18:02PM +0800, Jason Wang wrote:
> 
> 
> On 2017年07月26日 20:57, Michael S. Tsirkin wrote:
> > On Wed, Jul 26, 2017 at 04:03:17PM +0800, Jason Wang wrote:
> > > This reverts commit 809ecb9bca6a9424ccd392d67e368160f8b76c92. Since it
> > > was reported to break vhost_net. We want to cache used event and use
> > > it to check for notification. We try to valid cached used event by
> > > checking whether or not it was ahead of new, but this is not correct
> > > all the time, it could be stale and there's no way to know about this.
> > > 
> > > Signed-off-by: Jason Wang<jasowang@redhat.com>
> > Could you supply a bit more data here please?  How does it get stale?
> > What does guest need to do to make it stale?  This will be helpful if
> > anyone wants to bring it back, or if we want to extend the protocol.
> > 
> 
> The problem we don't know whether or not guest has published a new used
> event. The check vring_need_event(vq->last_used_event, new + vq->num, new)
> is not sufficient to check for this.
> 
> Thanks

Figured it out after an offline discussion.
