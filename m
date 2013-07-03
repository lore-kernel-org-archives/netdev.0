From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio-net: fix the race between channels setting
	and refill
Date: Wed, 03 Jul 2013 16:59:45 -0700 (PDT)
Message-ID: <20130703.165945.721617006723749470.davem@davemloft.net>
References: <1372853752-41889-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, sasha.levin@oracle.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1372853752-41889-1-git-send-email-jasowang@redhat.com>
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
Date: Wed,  3 Jul 2013 20:15:52 +0800

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

Michael, please review.

Thanks.
