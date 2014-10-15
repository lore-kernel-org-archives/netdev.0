From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next RFC 1/3] virtio: support for urgent descriptors
Date: Wed, 15 Oct 2014 16:10:02 +1030
Message-ID: <877g01c2ml.fsf@rustcorp.com.au>
References: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
	<1413011806-3813-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-api@vger.kernel.org, kvm@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1413011806-3813-2-git-send-email-jasowang@redhat.com>
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

Jason Wang <jasowang@redhat.com> writes:
> Below should be useful for some experiments Jason is doing.
> I thought I'd send it out for early review/feedback.
>
> event idx feature allows us to defer interrupts until
> a specific # of descriptors were used.
> Sometimes it might be useful to get an interrupt after
> a specific descriptor, regardless.
> This adds a descriptor flag for this, and an API
> to create an urgent output descriptor.
> This is still an RFC:
> we'll need a feature bit for drivers to detect this,
> but we've run out of feature bits for virtio 0.X.
> For experimentation purposes, drivers can assume
> this is set, or add a driver-specific feature bit.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

The new VRING_DESC_F_URGENT bit is theoretically nicer, but for
networking (which tends to take packets in order) couldn't we just set
the event counter to give us a tx interrupt at the packet we want?

Cheers,
Rusty.
