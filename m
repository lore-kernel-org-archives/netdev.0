From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] tun: introduce tx skb ring
Date: Thu, 16 Jun 2016 17:01:31 -0700 (PDT)
Message-ID: <20160616.170131.1753206993488742551.davem@davemloft.net>
References: <1465979897-4445-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, eric.dumazet@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, brouer@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1465979897-4445-1-git-send-email-jasowang@redhat.com>
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
Date: Wed, 15 Jun 2016 16:38:17 +0800

> We used to queue tx packets in sk_receive_queue, this is less
> efficient since it requires spinlocks to synchronize between producer
> and consumer.
> 
> This patch tries to address this by:
> 
> - introduce a new mode which will be only enabled with IFF_TX_ARRAY
>   set and switch from sk_receive_queue to a fixed size of skb
>   array with 256 entries in this mode.
> - introduce a new proto_ops peek_len which was used for peeking the
>   skb length.
> - implement a tun version of peek_len for vhost_net to use and convert
>   vhost_net to use peek_len if possible.
> 
> Pktgen test shows about 18% improvement on guest receiving pps for small
> buffers:
> 
> Before: ~1220000pps
> After : ~1440000pps
> 
> The reason why I stick to new mode is because:
> 
> - though resize is supported by skb array, in multiqueue mode, it's
>   not easy to recover from a partial success of queue resizing.
> - tx_queue_len is a user visible feature.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Michael, can you please review this, especially as this is the first
user of your new infrastructure :-)
