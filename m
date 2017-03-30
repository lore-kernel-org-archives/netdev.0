From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: fix mergeable bufs error handling
Date: Thu, 30 Mar 2017 10:57:06 -0700 (PDT)
Message-ID: <20170330.105706.320793115840611639.davem@davemloft.net>
References: <1490791050-22046-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1490791050-22046-1-git-send-email-mst@redhat.com>
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
Date: Wed, 29 Mar 2017 15:37:37 +0300

> @@ -570,7 +570,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  	u16 num_buf;
>  	struct page *page;
>  	int offset;
> -	struct sk_buff *head_skb, *curr_skb;
> +	struct sk_buff *head_skb = NULL, *curr_skb;
>  	struct bpf_prog *xdp_prog;
>  	unsigned int truesize;
>  

Like Jason, I see the very next line is:

	head_skb = NULL;

so I don't think this is necessary.
