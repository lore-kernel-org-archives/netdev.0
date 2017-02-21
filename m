From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] virito-net: set queues after reset during
	xdp_set
Date: Mon, 20 Feb 2017 22:23:09 -0500 (EST)
Message-ID: <20170220.222309.245000834571259773.davem@davemloft.net>
References: <1487562620-10146-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	john.fastabend@gmail.com, linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1487562620-10146-1-git-send-email-jasowang@redhat.com>
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
Date: Mon, 20 Feb 2017 11:50:20 +0800

> We set queues before reset which will cause a crash[1]. This is
> because is_xdp_raw_buffer_queue() depends on the old xdp queue pairs
> number to do the correct detection. So fix this by
> 
> - passing xdp queue pairs and current queue pairs to virtnet_reset()
> - change vi->xdp_qp after reset but before refill, to make sure both
>   free_unused_bufs() and refill can make correct detection of XDP.
> - remove the duplicated queue pairs setting before virtnet_reset()
>   since we will do it inside virtnet_reset()
> 
> [1]
 ...
> Fixes: 2de2f7f40ef9 ("virtio_net: XDP support for adjust_head")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable, thanks Jason.
