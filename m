From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/4] net: allow > 0 order atomic page alloc in
	skb_page_frag_refill
Date: Tue, 12 Nov 2013 14:42:50 -0800
Message-ID: <1384296170.28458.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384294885-6444-1-git-send-email-mwdalton@google.com>
	<1384294885-6444-2-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1384294885-6444-2-git-send-email-mwdalton@google.com>
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

On Tue, 2013-11-12 at 14:21 -0800, Michael Dalton wrote:
> skb_page_frag_refill currently permits only order-0 page allocs
> unless GFP_WAIT is used. Change skb_page_frag_refill to attempt
> higher-order page allocations whether or not GFP_WAIT is used. If
> memory cannot be allocated, the allocator will fall back to
> successively smaller page allocs (down to order-0 page allocs).
> 
> This change brings skb_page_frag_refill in line with the existing
> page allocation strategy employed by netdev_alloc_frag, which attempts
> higher-order page allocations whether or not GFP_WAIT is set, falling
> back to successively lower-order page allocations on failure. Part
> of migration of virtio-net to per-receive queue page frag allocators.
> 
> Signed-off-by: Michael Dalton <mwdalton@google.com>
> ---
>  net/core/sock.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
