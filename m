From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio-net: correct error handling of virtqueue_kick()
Date: Thu, 27 Mar 2014 13:14:11 -0400 (EDT)
Message-ID: <20140327.131411.1257894502376926151.davem@davemloft.net>
References: <1395810180-35169-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1395810180-35169-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 26 Mar 2014 13:03:00 +0800

> Current error handling of virtqueue_kick() was wrong in two places:
> - The skb were freed immediately when virtqueue_kick() fail during
>   xmit. This may lead double free since the skb was not detached from
>   the virtqueue.
> - try_fill_recv() returns false when virtqueue_kick() fail. This will
>   lead unnecessary rescheduling of refill work.
> 
> Actually, it's safe to just ignore the kick failure in those two
> places. So this patch fixes this by partially revert commit
> 67975901183799af8e93ec60e322f9e2a1940b9b.
> 
> Fixes 67975901183799af8e93ec60e322f9e2a1940b9b
> (virtio_net: verify if virtqueue_kick() succeeded).
> 
> Cc: Heinz Graalfs <graalfs@linux.vnet.ibm.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable, thanks.
