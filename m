From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vhost: fix a theoretical race in device cleanup
Date: Thu, 13 Feb 2014 18:48:25 -0500 (EST)
Message-ID: <20140213.184825.32399543190618715.davem@davemloft.net>
References: <1392284540-2031-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1392284540-2031-1-git-send-email-mst@redhat.com>
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
Date: Thu, 13 Feb 2014 11:45:11 +0200

> vhost_zerocopy_callback accesses VQ right after it drops a ubuf
> reference.  In theory, this could race with device removal which waits
> on the ubuf kref, and crash on use after free.
> 
> Do all accesses within rcu read side critical section, and synchronize
> on release.
> 
> Since callbacks are always invoked from bh, synchronize_rcu_bh seems
> enough and will help release complete a bit faster.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> This is was previously posted as part of patch
> series, but it's an independent fix really.
> Theoretical race so not needed for stable I think.

Ok, no -stable, applied.
