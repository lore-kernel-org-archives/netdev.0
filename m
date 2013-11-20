From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] virtio-net: fix page refcnt leaking when fail to
	allocate frag skb
Date: Wed, 20 Nov 2013 11:00:41 +0800
Message-ID: <528C25D9.6030605@redhat.com>
References: <1384848307-7217-1-git-send-email-jasowang@redhat.com>
	<1384869828.8604.97.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1384869828.8604.97.camel@edumazet-glaptop2.roam.corp.google.com>
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

On 11/19/2013 10:03 PM, Eric Dumazet wrote:
> On Tue, 2013-11-19 at 16:05 +0800, Jason Wang wrote:
>> > We need to drop the refcnt of page when we fail to allocate an skb for frag
>> > list, otherwise it will be leaked. The bug was introduced by commit
>> > 2613af0ed18a11d5c566a81f9a6510b73180660a ("virtio_net: migrate mergeable rx
>> > buffers to page frag allocators").
>> > 
>> > Cc: Michael Dalton <mwdalton@google.com>
>> > Cc: Eric Dumazet <edumazet@google.com>
>> > Cc: Rusty Russell <rusty@rustcorp.com.au>
>> > Cc: Michael S. Tsirkin <mst@redhat.com>
>> > Signed-off-by: Jason Wang <jasowang@redhat.com>
>> > ---
>> > The patch was needed for 3.12 stable.
> Good catch, but if we return from receive_mergeable() in the 'middle'
> of the frags we would need for the current skb, who will
> call the virtqueue_get_buf() to flush the remaining frags ?
>
> Don't we also need to call virtqueue_get_buf() like 
>
> while (--num_buf) {
>     buf = virtqueue_get_buf(rq->vq, &len);
>     if (!buf)
>         break;
>     put_page(virt_to_head_page(buf));
> }
>
> ?

Yes we need this, will send V2.

Thanks
