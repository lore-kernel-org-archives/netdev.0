From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next V2] tun: introduce tx skb ring
Date: Wed, 15 Jun 2016 07:52:47 -0400
Message-ID: <5761418F.2050407@mojatatu.com>
References: <1465979897-4445-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, brouer@redhat.com
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465979897-4445-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-06-15 04:38 AM, Jason Wang wrote:
> We used to queue tx packets in sk_receive_queue, this is less
> efficient since it requires spinlocks to synchronize between producer
> and consumer.
> 
> This patch tries to address this by:
> 
> - introduce a new mode which will be only enabled with IFF_TX_ARRAY
>    set and switch from sk_receive_queue to a fixed size of skb
>    array with 256 entries in this mode.
> - introduce a new proto_ops peek_len which was used for peeking the
>    skb length.
> - implement a tun version of peek_len for vhost_net to use and convert
>    vhost_net to use peek_len if possible.
> 
> Pktgen test shows about 18% improvement on guest receiving pps for small
> buffers:
> 
> Before: ~1220000pps
> After : ~1440000pps
> 

So this is more exercising the skb array improvements. For tun
it would be useful to see general performance numbers on user/kernel
crossing (i.e tun read/write).
If you have the cycles can you run such tests?

cheers,
jamal
