From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/4] net: allow > 0 order atomic page alloc
	in skb_page_frag_refill
Date: Wed, 08 Jan 2014 14:01:00 -0800
Message-ID: <1389218460.31367.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<20140108180829.GB18162@redhat.com>
	<1389205563.31367.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140108191803.GB18312@redhat.com>
	<1389210371.31367.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAATkVEypFGfXuiBwFacOMjAWyYmLXHiihdpQfJp+CRFEZJagyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jbaron@akamai.com, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, Joshua Hunt <johunt@akamai.com>,
	"David S. Miller" <davem@davemloft.net>
To: Debabrata Banerjee <dbavatar@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAATkVEypFGfXuiBwFacOMjAWyYmLXHiihdpQfJp+CRFEZJagyg@mail.gmail.com>
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

On Wed, 2014-01-08 at 16:54 -0500, Debabrata Banerjee wrote:

> Actually I have more data on this:
> 

Could you please stop polluting this thread ?

> 1. __GFP_NORETRY really does help and should go into stable tree.
> 

Not at all. You are free to patch your kernel if you want.

It helps you workload, and breaks all others.

If compaction is never triggered, we'll never be able to get high order
pages, and performance goes back to what we had 2 years ago.

That discussion does not belong to this thread, again.

> 2. You may want to consider GFP_NOKSWAPD, because even in the
> GFP_ATOMIC case you are waking up kswapd to do reclaims on a
> continuous basis even when you don't enter direct reclaim.
> 
> 3. mlocking memory had very little to do with it, that was a
> red-herring. I tested out the problem scenario with no mlocks. You
> simply need memory pressure from page_cache, and mm ends up constantly
> reclaiming and trying to keep another 1-2GB free on our systems (8GB
> phys ~4GB left for kernel, ~3GB optimally used for page_cache).
> 
> 4. I think perhaps using a kmem_cache allocation for this buffer is
> the right way to make this work. I am experimenting with a patch to do
> this.

Seriously... I think you missed whole point of having frag allocation on
pages, not kmem_cache.
