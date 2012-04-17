From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 5/6] vhost_net: fix use after free of vq->ubufs
Date: Tue, 17 Apr 2012 13:22:20 +0300
Message-ID: <20120417102220.GC20905@redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
 <20120416060825.14140.32069.stgit@intel-e5620-16-2.englab.nay.redhat.com>
 <20120416132841.GB13113@redhat.com>
 <4F8CE14E.5080508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F8CE14E.5080508@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2012 at 11:19:42AM +0800, Jason Wang wrote:
> On 04/16/2012 09:28 PM, Michael S. Tsirkin wrote:
> >On Mon, Apr 16, 2012 at 02:08:25PM +0800, Jason Wang wrote:
> >>When zerocopy socket is used, ubufs pointer were used in handle_tx()
> >>without any validation. This would cause NULL pointer deference after
> >>it has been freed in vhost_net_set_backend(). Fix this by check the
> >>pointer before using it.
> >>
> >>Signed-off-by: Jason Wang<jasowang@redhat.com>
> >
> >OK so it's NULL dereference and not user after free :)
> >Also could you clarify how does this happen pls?
> >Don't we always initialize ubufs when vhost_sock_zcopy is set?
> 
> The problem happens when we want to disable backend. At this time
> ubufs were assigned to NULL and it may be dereferenced by
> handle_tx():

Heh, I see. How about
- zcopy = vhost_sock_zcopy(sock);
+ zcopy = vq->ubufs;

-- 
MST
