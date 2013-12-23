From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: allow > 0 order atomic page alloc in
	skb_page_frag_refill
Date: Mon, 23 Dec 2013 09:30:38 -0800
Message-ID: <1387819838.12212.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<20131223125321.GB18168@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131223125321.GB18168@redhat.com>
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

On Mon, 2013-12-23 at 14:53 +0200, Michael S. Tsirkin wrote:
> On Mon, Dec 16, 2013 at 04:16:27PM -0800, Michael Dalton wrote:
> > skb_page_frag_refill currently permits only order-0 page allocs
> > unless GFP_WAIT is used. Change skb_page_frag_refill to attempt
> > higher-order page allocations whether or not GFP_WAIT is used. If
> > memory cannot be allocated, the allocator will fall back to
> > successively smaller page allocs (down to order-0 page allocs).
> > 
> > This change brings skb_page_frag_refill in line with the existing
> > page allocation strategy employed by netdev_alloc_frag, which attempts
> > higher-order page allocations whether or not GFP_WAIT is set, falling
> > back to successively lower-order page allocations on failure. Part
> > of migration of virtio-net to per-receive queue page frag allocators.
> > 
> > Signed-off-by: Michael Dalton <mwdalton@google.com>
> 
> I don't get how this is related to patch 3/3 exactly.
> That one seems to clamp the allocations from ewma to at most
> PAGE_SIZE, so how to we get higher-order allocations here?
> Could you clarify please?

If your ewma stabilizes at 2050 bytes per frag, using order-0 page will
waste ~50% of memory.
