From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv4] virtio-spec: virtio network device multiqueue support
Date: Wed, 19 Sep 2012 11:10:10 +0930
Message-ID: <87wqzqpz7p.fsf@rustcorp.com.au>
References: <20120909130308.GA3471@redhat.com> <878vcifwxi.fsf@rustcorp.com.au>
	<20120910061629.GC16819@redhat.com>
	<20120910062738.GA17331@redhat.com>
	<20120910063346.GA17338@redhat.com>
	<504DC831.1000709@redhat.com> <87har3dc4o.fsf@rustcorp.com.au>
	<CA+mtBx_Kjp62UYJs-7OSFsFKndx6H1oOkuD8U3ooAUuR1PMF=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, rick.jones2@hp.com,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, pbonzini@redhat.com
To: Tom Herbert <therbert@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CA+mtBx_Kjp62UYJs-7OSFsFKndx6H1oOkuD8U3ooAUuR1PMF=Q@mail.gmail.com>
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

Tom Herbert <therbert@google.com> writes:
> On Tue, Sep 11, 2012 at 10:49 PM, Rusty Russell <rusty@rustcorp.com.au>wrote:
>> Perhaps Tom can explain how we avoid out-of-order receive for the
>> accelerated RFS case?  It's not clear to me, but we need to be able to
>> do that for virtio-net if it implements accelerated RFS.
>
> AFAIK ooo RX is possible with accelerated RFS.  We have an algorithm that
> prevents this for RFS case by deferring a migration to a new queue as long
> as it's possible that a flow might have outstanding packets on the old
> queue.  I suppose this could be implemented in the device for the HW
> queues, but I don't think it would be easy to cover all cases where packets
> were already in transit to the host or other cases where host and device
> queues are out of sync.

Having gone to such great lengths to avoid ooo for RFS, I don't think
DaveM would be happy if we allow it for virtio_net.

So, how *would* we implement such a thing for a "hardware" device?  What
if the device will only change the receive queue if the old receive
queue is empty?

Cheers,
Rusty.
