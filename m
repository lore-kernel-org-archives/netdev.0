From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net] virtio-net: fix the race between channels setting and refill
Date: Thu, 04 Jul 2013 11:48:31 +0930
Message-ID: <877gh7f4p4.fsf@rustcorp.com.au>
References: <1372853752-41889-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372853752-41889-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Wang <jasowang@redhat.com> writes:
> Commit 55257d72bd1c51f25106350f4983ec19f62ed1fa (virtio-net: fill only rx queues
> which are being used) tries to refill on demand when changing the number of
> channels by call try_refill_recv() directly, this may race:
>
> - the refill work who may do the refill in the same time
> - the try_refill_recv() called in bh since napi was not disabled
>
> Which may led guest complain during setting channels:
>
> virtio_net virtio0: input.1:id 0 is not a head!
>
> Solve this issue by scheduling a refill work which can guarantee the
> serialization of refill.
>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Thanks.

Applied,
Rusty.
