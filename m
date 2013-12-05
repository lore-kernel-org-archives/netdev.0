From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] virtio-net: free bufs correctly on invalid packet length
Date: Fri, 06 Dec 2013 01:08:57 +0300
Message-ID: <52A0F979.1090309@cogentembedded.com>
References: <1386274612-18379-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Andrey Vagin <avagin@openvz.org>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: Michael Dalton <mwdalton@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1386274612-18379-1-git-send-email-mwdalton@google.com>
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

Hello.

On 12/05/2013 11:16 PM, Michael Dalton wrote:

> When a packet with invalid length arrives, ensure that the packet
> is freed correctly if mergeable packet buffers and big packets
> (GUEST_TSO4) are both enabled.

    Looks like a similar patch have been posted by Andrey Vagin today. You 
also forgot to sign off the patch, so it can't be applied anyway.

> ---
>   drivers/net/virtio_net.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 916241d..6a4665c 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -426,10 +426,10 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>   	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
>   		pr_debug("%s: short packet %i\n", dev->name, len);
>   		dev->stats.rx_length_errors++;
> -		if (vi->big_packets)
> -			give_pages(rq, buf);
> -		else if (vi->mergeable_rx_bufs)
> +		if (vi->mergeable_rx_bufs)
>   			put_page(virt_to_head_page(buf));
> +		else if (vi->big_packets)
> +			give_pages(rq, buf);
>   		else
>   			dev_kfree_skb(buf);
>   		return;

WBR, Sergei
