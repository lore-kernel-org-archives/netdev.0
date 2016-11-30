From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] vhost_net: don't continue to call the recvmsg when
 meet errors
Date: Wed, 30 Nov 2016 15:43:48 +0200
Message-ID: <20161130154250-mutt-send-email-mst@kernel.org>
References: <1480507857-22976-1-git-send-email-wangyunjian@huawei.com>
 <e4ac063d-db9f-ec93-30cd-163375ececfc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Yunjian Wang <wangyunjian@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, caihe@huawei.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55342 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755752AbcK3Nny (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 08:43:54 -0500
Content-Disposition: inline
In-Reply-To: <e4ac063d-db9f-ec93-30cd-163375ececfc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 09:07:16PM +0800, Jason Wang wrote:
> 
> 
> On 2016年11月30日 20:10, Yunjian Wang wrote:
> > When we meet an error(err=-EBADFD) recvmsg, the error handling in vhost
> > handle_rx() will continue. This will cause a soft CPU lockup in vhost thread.
> > 
> > Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>
> > ---
> >   drivers/vhost/net.c | 3 +++
> >   1 file changed, 3 insertions(+)
> > 
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 5dc128a..edc470b 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -717,6 +717,9 @@ static void handle_rx(struct vhost_net *net)
> >   			pr_debug("Discarded rx packet: "
> >   				 " len %d, expected %zd\n", err, sock_len);
> >   			vhost_discard_vq_desc(vq, headcount);
> > +			/* Don't continue to do, when meet errors. */
> > +			if (err < 0)
> > +				goto out;
> >   			continue;
> >   		}
> >   		/* Supply virtio_net_hdr if VHOST_NET_F_VIRTIO_NET_HDR */
> 
> Acked-by: Jason Wang <jasowang@redhat.com>
> 
> We may want to rename vhost_discard_vq_desc() in the future, since it does
> not discard the desc in fact.

To me this looks a bit too aggressive. I would also like commit log
to explain better what is going on, to make sure we are
not just treating the symptoms.
-- 
MST
