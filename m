From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PowerPC] Next May 8 boot failure: OOPS during ibmveth moduleinit
Date: Tue, 12 May 2009 10:16:44 +0200
Message-ID: <20090512081643.GC3399@psychotron.englab.brq.redhat.com>
References: <20090508180251.f53f204e.sfr@canb.auug.org.au>
	<4A042B20.4090903@in.ibm.com>
	<20090508.125722.54378771.davem@davemloft.net>
	<20090508223332.GA4881@psychotron.englab.brq.redhat.com>
	<4A085B3D.5000806@in.ibm.com>
	<20090512170458.39c4ffb7.sfr@canb.auug.org.au>
	<20090512174451.eeed4126.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, linux-next@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20090512174451.eeed4126.sfr@canb.auug.org.au>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Tue, May 12, 2009 at 09:44:51AM CEST, sfr@canb.auug.org.au wrote:
>Hi Dave,
>
>This fixes it (I wonder if this bug is lurking in any other drivers):
Grepping the sources I see some other places suffering this problem. I'll send
patch for this.
>
>From: Stephen Rothwell <sfr@canb.auug.org.au>
>Date: Tue, 12 May 2009 17:24:02 +1000
>Subject: [PATCH] net/ibmveth: fix panic in probe
>
>netdev->dev_addr changed from being an array to being a pointer, so we
>should not take its address for memcpy().
Nice!
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>---
> drivers/net/ibmveth.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
>index 7902e5e..8daffad 100644
>--- a/drivers/net/ibmveth.c
>+++ b/drivers/net/ibmveth.c
>@@ -1285,7 +1285,7 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
>  	netdev->features |= NETIF_F_LLTX;
> 	spin_lock_init(&adapter->stats_lock);
> 
>-	memcpy(&netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
>+	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
> 
> 	for(i = 0; i<IbmVethNumBufferPools; i++) {
> 		struct kobject *kobj = &adapter->rx_buff_pool[i].kobj;
>-- 
>1.6.3
>
>
>-- 
>Cheers,
>Stephen Rothwell                    sfr@canb.auug.org.au
>http://www.canb.auug.org.au/~sfr/
