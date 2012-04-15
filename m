From: David Miller <davem@davemloft.net>
Subject: Re: [net-next V7 PATCH] virtio-net: send gratuitous packets when
	needed
Date: Sun, 15 Apr 2012 03:20:03 -0400 (EDT)
Message-ID: <20120415.032003.138761548777211783.davem@davemloft.net>
References: <20120412064351.23243.84912.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120415071223.GC3070@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120415071223.GC3070@redhat.com>
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

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 15 Apr 2012 10:12:23 +0300

> On Thu, Apr 12, 2012 at 02:43:52PM +0800, Jason Wang wrote:
>> As hypervior does not have the knowledge of guest network configuration, it's
>> better to ask guest to send gratuitous packets when needed.
>> 
>> This patch implements VIRTIO_NET_F_GUEST_ANNOUNCE feature: hypervisor would
>> notice the guest when it thinks it's time for guest to announce the link
>> presnece. Guest tests VIRTIO_NET_S_ANNOUNCE bit during config change interrupt
>> and woule send gratuitous packets through netif_notify_peers() and ack the
>> notification through ctrl vq.
>> 
>> We need to make sure the atomicy of read and ack in guest otherwise we may ack
>> more times than being notified. This is done through handling the whole config
>> change interrupt in an non-reentrant workqueue.
>> 
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks everyone.
