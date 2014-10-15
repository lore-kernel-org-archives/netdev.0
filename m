From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC] virtio_net: enable tx interrupt
Date: Wed, 15 Oct 2014 12:33:48 +0800
Message-ID: <543DF92C.6060209@redhat.com>
References: <1413323524-23380-1-git-send-email-mst@redhat.com>
	<20141014231154.GA23806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141014231154.GA23806@redhat.com>
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

On 10/15/2014 07:11 AM, Michael S. Tsirkin wrote:
> On Wed, Oct 15, 2014 at 12:53:59AM +0300, Michael S. Tsirkin wrote:
>> >  static void skb_xmit_done(struct virtqueue *vq)
>> >  {
>> >  	struct virtnet_info *vi = vq->vdev->priv;
>> > +	struct send_queue *sq = &vi->sq[vq2txq(vq)];
>> >  
>> > -	/* Suppress further interrupts. */
>> > -	virtqueue_disable_cb(vq);
>> > -
> One note here: current code seems racy because of doing
> virtqueue_disable_cb from skb_xmit_done that I'm dropping here: there's
> no guarantee we don't get an interrupt while tx ring is running, and if
> that happens we can end up with interrupts disabled forever.
>

Looks harmless since:

- if event index is enabled, virtqueue_disable_cb() does nothing in fact.
- if event index is disabled, we don't depend on tx interrupt and when
num_free is low we will try to enable the tx interrupt again.
