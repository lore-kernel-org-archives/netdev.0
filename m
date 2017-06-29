From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio-net: serialize tx routine during reset
Date: Thu, 29 Jun 2017 12:52:41 -0400 (EDT)
Message-ID: <20170629.125241.1456732917773572552.davem@davemloft.net>
References: <1498614663-7711-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, john.fastabend@gmail.com,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, jpmenil@gmail.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1498614663-7711-1-git-send-email-jasowang@redhat.com>
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
Date: Wed, 28 Jun 2017 09:51:03 +0800

> We don't hold any tx lock when trying to disable TX during reset, this
> would lead a use after free since ndo_start_xmit() tries to access
> the virtqueue which has already been freed. Fix this by using
> netif_tx_disable() before freeing the vqs, this could make sure no tx
> after vq freeing.
> 
> Reported-by: Jean-Philippe Menil <jpmenil@gmail.com>
> Tested-by: Jean-Philippe Menil <jpmenil@gmail.com>
> Fixes commit f600b6905015 ("virtio_net: Add XDP support")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable.
