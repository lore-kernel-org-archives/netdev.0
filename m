From: David Miller <davem@davemloft.net>
Subject: Re: [net-next V7 PATCH] virtio-net: send gratuitous packets when
	needed
Date: Fri, 13 Apr 2012 13:38:04 -0400 (EDT)
Message-ID: <20120413.133804.1504347944886702242.davem@davemloft.net>
References: <20120412064351.23243.84912.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120412064351.23243.84912.stgit@amd-6168-8-1.englab.nay.redhat.com>
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
Date: Thu, 12 Apr 2012 14:43:52 +0800

> As hypervior does not have the knowledge of guest network configuration, it's
> better to ask guest to send gratuitous packets when needed.
> 
> This patch implements VIRTIO_NET_F_GUEST_ANNOUNCE feature: hypervisor would
> notice the guest when it thinks it's time for guest to announce the link
> presnece. Guest tests VIRTIO_NET_S_ANNOUNCE bit during config change interrupt
> and woule send gratuitous packets through netif_notify_peers() and ack the
> notification through ctrl vq.
> 
> We need to make sure the atomicy of read and ack in guest otherwise we may ack
> more times than being notified. This is done through handling the whole config
> change interrupt in an non-reentrant workqueue.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Michael, Rusty, et al.?
