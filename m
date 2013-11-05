From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 2/2] virtio-net: coalesce rx frags when
	possible during rx
Date: Mon, 04 Nov 2013 20:04:38 -0500 (EST)
Message-ID: <20131104.200438.1658727667787717171.davem@davemloft.net>
References: <1383286068-10421-1-git-send-email-jasowang@redhat.com>
	<1383286068-10421-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kmindg@gmail.com,
	edumazet@google.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1383286068-10421-2-git-send-email-jasowang@redhat.com>
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
Date: Fri,  1 Nov 2013 14:07:48 +0800

> Commit 2613af0ed18a11d5c566a81f9a6510b73180660a (virtio_net: migrate mergeable
> rx buffers to page frag allocators) try to increase the payload/truesize for
> MTU-sized traffic. But this will introduce the extra overhead for GSO packets
> received because of the frag list. This commit tries to reduce this issue by
> coalesce the possible rx frags when possible during rx. Test result shows the
> about 15% improvement on full size GSO packet receiving (and even better than
> before commit 2613af0ed18a11d5c566a81f9a6510b73180660a).
...
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael Dalton <mwdalton@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> Changes from V2:
> - call put_page() instead of depending on skb_coalesce_rx_frag()

Looks fantastic, applied, thanks Jason!
