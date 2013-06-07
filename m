From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: put virtio net header inline with data
Date: Fri, 07 Jun 2013 11:42:43 +0930
Message-ID: <87hahar7ms.fsf@rustcorp.com.au>
References: <20130606095456.GA7865@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: qemu-devel@nongnu.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>, Cong Wang <amwang@redhat.com>,
	Amos Kong <akong@redhat.com>, Dave Jones <davej@redhat.com>,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130606095456.GA7865@redhat.com>
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
> For small packets we can simplify xmit processing by linearizing buffers
> with the header: most packets seem to have enough head room we can use
> for this purpose.
>
> Since some older hypervisors (e.g. qemu before version 1.5)
> required that header is the first s/g element,
> we need a feature bit for this.

OK, we know this is horrible.  But I will sleep better knowing that we
this feature need never make it into a final 1.0 spec, since it can be
assumed at that point...

>  	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
> +	if (vi->mergeable_rx_bufs)
> +		hdr_len = sizeof hdr->mhdr;
> +	else
> +		hdr_len = sizeof hdr->hdr;
> +
> +	can_push = vi->any_header_sg &&
> +		!((unsigned long)skb->data & (__alignof__(*hdr) - 1)) &&
> +		!skb_header_cloned(skb) && skb_headroom(skb) >= hdr_len;

Idle thought: how often does this fail?  Would it suck if we copied
headers which didn't let us prepend data?  Or could we bump
dev->hard_header_len appropriately?

Thanks,
Rusty.
