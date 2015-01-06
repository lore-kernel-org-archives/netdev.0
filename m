From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 net-next 2/2 tuntap: Increase the number of queues in
 tun.
Date: Tue, 6 Jan 2015 11:49:12 +0200
Message-ID: <20150106094912.GA30222@redhat.com>
References: <1420522756-15127-1-git-send-email-pagupta@redhat.com>
 <1420522756-15127-3-git-send-email-pagupta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, jasowang@redhat.com, dgibson@redhat.com,
	vfalico@gmail.com, edumazet@google.com, vyasevic@redhat.com,
	hkchu@google.com, wuzhy@linux.vnet.ibm.com, xemul@parallels.com,
	therbert@google.com, bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei.shtylyov@cogentembedded.com
To: Pankaj Gupta <pagupta@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1420522756-15127-3-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 06, 2015 at 11:09:16AM +0530, Pankaj Gupta wrote:
> Networking under kvm works best if we allocate a per-vCPU RX and TX
> queue in a virtual NIC. This requires a per-vCPU queue on the host side.
> 
> It is now safe to increase the maximum number of queues.
> Preceding patch: 'net: allow large number of rx queues'
> made sure this won't cause failures due to high order memory
> allocations. Increase it to 256: this is the max number of vCPUs
> KVM supports.
> 
> Size of tun_struct changes from 8512 to 10496 after this patch. This keeps 
> pages allocated for tun_struct before and after the patch to 3. 
> 
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> Reviewed-by: David Gibson <dgibson@redhat.com>
> ---
>  drivers/net/tun.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index e3fa65a..a19dc5f8 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -113,10 +113,11 @@ struct tap_filter {
>  	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
>  };
>  
> -/* DEFAULT_MAX_NUM_RSS_QUEUES were chosen to let the rx/tx queues allocated for
> - * the netdevice to be fit in one page. So we can make sure the success of
> - * memory allocation. TODO: increase the limit. */
> -#define MAX_TAP_QUEUES DEFAULT_MAX_NUM_RSS_QUEUES
> +/* MAX_TAP_QUEUES 256 is chosen to allow rx/tx queues to be equal
> + * to max number of vCPUS in guest.

VCPUs I think.

> Also, we are making sure here
> + * queue memory allocation do not fail.

What does this mean? How are we making sure?
I would drop this phrase really.

> + */
> +#define MAX_TAP_QUEUES 256
>  #define MAX_TAP_FLOWS  4096
>  
>  #define TUN_FLOW_EXPIRE (3 * HZ)
> -- 
> 1.8.3.1
