From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [V2 PATCH 9/9] vhost: zerocopy: poll vq in zerocopy callback
Date: Wed, 16 May 2012 18:14:44 +0300
Message-ID: <20120516151444.GC9934@redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
 <20120502034254.11782.27314.stgit@amd-6168-8-1.englab.nay.redhat.com>
 <1337100630.8220.4.camel@oc3660625478.ibm.com>
 <4FB317C8.90002@redhat.com>
 <1337181027.10741.13.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337181027.10741.13.camel@oc3660625478.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2012 at 08:10:27AM -0700, Shirley Ma wrote:
> On Wed, 2012-05-16 at 10:58 +0800, Jason Wang wrote:
> > >>   drivers/vhost/vhost.c |    1 +
> > >>   1 files changed, 1 insertions(+), 0 deletions(-)
> > >>
> > >> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > >> index 947f00d..7b75fdf 100644
> > >> --- a/drivers/vhost/vhost.c
> > >> +++ b/drivers/vhost/vhost.c
> > >> @@ -1604,6 +1604,7 @@ void vhost_zerocopy_callback(void *arg)
> > >>          struct vhost_ubuf_ref *ubufs = ubuf->arg;
> > >>          struct vhost_virtqueue *vq = ubufs->vq;
> > >>
> > >> +       vhost_poll_queue(&vq->poll);
> > >>          /* set len = 1 to mark this desc buffers done DMA */
> > >>          vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
> > >>          kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
> > > Doing so, we might have redundant vhost_poll_queue(). Do you know in
> > > which scenario there might be missing of adding and signaling during
> > > zerocopy?
> > 
> > Yes, as we only do signaling and adding during tx work, if there's no
> > tx 
> > work when the skb were sent, we may lose the opportunity to let guest 
> > know about the completion. It's easy to be reproduced with netperf
> > test. 
> 
> The reason which host signals guest is to free guest tx buffers, if
> there is no tx work, then it's not necessary to signal the guest unless
> guest runs out of memory. The pending buffers will be released
> virtio_net device gone.
> 
> What's the behavior of netperf test when you hit this situation?
> 
> Thanks
> Shirley

IIRC guest networking seems to be lost.


-- 
MST
