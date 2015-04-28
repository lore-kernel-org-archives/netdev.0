From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
Date: Tue, 28 Apr 2015 02:57:12 +0000
Message-ID: <98aada63cb294d9ea4eb7807ccb42baa@SIXPR30MB031.064d.mgd.msft.net>
References: <1430183690-24198-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KY Srinivasan <kys@microsoft.com>, "davem@davemloft.net"
 <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1430183690-24198-1-git-send-email-kys@microsoft.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: devel [mailto:driverdev-devel-bounces@linuxdriverproject.org] On
> Behalf Of K. Y. Srinivasan
> Sent: Tuesday, April 28, 2015 9:15
> To: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: [PATCH net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
> 
> Commit commit b08cc79155fc26d0d112b1470d1ece5034651a4b
> eliminated memory
> allocation in the packet send path. This commit introduced a bug since it
> did not account for the case if the skb was cloned. Fix this bug by
> using the pre-reserved head room only if the skb is not cloned.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/hyperv/netvsc_drv.c
> b/drivers/net/hyperv/netvsc_drv.c
> index a3a9d38..7eb0251 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -421,7 +421,7 @@ check_size:
> 
>  	pkt_sz = sizeof(struct hv_netvsc_packet) + RNDIS_AND_PPI_SIZE;
> 
> -	if (head_room < pkt_sz) {
> +	if (skb->cloned ||  head_room < pkt_sz) {
>  		packet = kmalloc(pkt_sz, GFP_ATOMIC);
>  		if (!packet) {
>  			/* out of memory, drop packet */
> --

Without the patch, the guest can panic due to memory corruption.

I confirm the patch can fix the panic I saw.

Tested-by: Dexuan Cui <decui@microsoft.com>

Thanks,
-- Dexuan
