From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: migrate mergeable rx buffers to
	page frag allocators
Date: Tue, 29 Oct 2013 21:12:50 +0200
Message-ID: <20131029191250.GE20848@redhat.com>
References: <1383000258-1458-1-git-send-email-mwdalton@google.com>
	<1383002389.4344.7.camel@edumazet-glaptop.roam.corp.google.com>
	<20131028.235721.919284648105056096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ffusco@redhat.com, mwdalton@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, dborkman@redhat.com,
	virtualization@lists.linux-foundation.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20131028.235721.919284648105056096.davem@davemloft.net>
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

On Mon, Oct 28, 2013 at 11:57:21PM -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 28 Oct 2013 16:19:49 -0700
> 
> > On Mon, 2013-10-28 at 15:44 -0700, Michael Dalton wrote:
> >> The virtio_net driver's mergeable receive buffer allocator
> >> uses 4KB packet buffers. For MTU-sized traffic, SKB truesize
> >> is > 4KB but only ~1500 bytes of the buffer is used to store
> >> packet data, reducing the effective TCP window size
> >> substantially. This patch addresses the performance concerns
> >> with mergeable receive buffers by allocating MTU-sized packet
> >> buffers using page frag allocators. If more than MAX_SKB_FRAGS
> >> buffers are needed, the SKB frag_list is used.
> >> 
> >> Signed-off-by: Michael Dalton <mwdalton@google.com>
> >> ---
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > 
> > Daniel & Francesco, this should address the performance problem you
> > tried to address with ("tcp: rcvbuf autotuning improvements") 
> > 
> > ( http://www.spinics.net/lists/netdev/msg252642.html )
> 
> Applied, thanks everyone.

Hmm that was very quick. It *should* fix a bug, great.
But how about we wait for some Tested-by reports that it actually does?

-- 
MST
