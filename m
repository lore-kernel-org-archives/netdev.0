From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv4] virtio-spec: virtio network device multiqueue support
Date: Wed, 12 Sep 2012 09:59:16 +0930
Message-ID: <87txv4ccdf.fsf@rustcorp.com.au>
References: <20120909130308.GA3471@redhat.com> <878vcifwxi.fsf@rustcorp.com.au>
	<20120910061629.GC16819@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, rick.jones2@hp.com,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, pbonzini@redhat.com,
	Tom Herbert <therbert@google.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120910061629.GC16819@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> In other words RPS is a hack to speed up networking on cheapo
> hardware, this is one of the reasons it is off by default.
> Good hardware has multiple receive queues.
> We can implement a good one so we do not need RPS.
>
> Also not all guest OS-es support RPS.
>
> Does this clarify?

Ok, thanks.

BTW, I found a better description by Tom Herbert, BTW:
        https://code.google.com/p/kernel/wiki/NetScalingGuide

Now, I find the description of VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX
confusing:

1) AFAICT it turns on multiqueue rx, with no semantics attached.
   I have no idea why it's called what it is.  Why?

2) We've said we can remove steering methods, but we haven't actually
   defined any, as we've left it completely open.

If I were a driver author, it leaves me completely baffled on how to
implement the spec :(

What are we actually planning to implement at the moment?

>For best performance, packets from a single connection should utilize
>the paired transmit and receive queues from the same virtqueue pair;
>for example both transmitqN and receiveqN. This rule makes it possible
>to optimize processing on the device side, but this is not a hard
>requirement: devices should function correctly even when this rule is
>not followed.

Why is this true?  I don't actually see why the queues are in pairs at
all; are tx and rx not completely independent?  So why does it matter?

>> When the steering rule is modified, some packets can still be
>> outstanding in one or more of the virtqueues. Device is not required
>> to wait for these packets to be consumed before delivering packets
>> using the new streering rule. Drivers modifying the steering rule at
>> a high rate (e.g. adaptively in response to changes in the workload)
>> are recommended to complete processing of the receive queue(s)
>> utilized by the original steering before processing any packets
>> delivered by the modified steering rule.

How can this be done?  This isn't actually possible without taking the
queue down, since more packets are incoming.

Cheers,
Rusty.
