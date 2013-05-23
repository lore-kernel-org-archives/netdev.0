From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next RFC 4/8] macvlan: reduce the max number of taps to 8
Date: Thu, 23 May 2013 09:37:40 +0300
Message-ID: <20130523063740.GA14703@redhat.com>
References: <1369278753-2533-1-git-send-email-jasowang@redhat.com>
 <1369278753-2533-5-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369278753-2533-5-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 23, 2013 at 11:12:29AM +0800, Jason Wang wrote:
> To be same with tap.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Well for tap the very specific reason was that
there's an array of big queue structures,
so we need to limit it to make it fit in a page.
No such reason here right?

We need at least as much as tap to be compatible, so
let's just make it 16 unconditionally?

> ---
>  include/linux/if_macvlan.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
> index e47ad46..32e943a 100644
> --- a/include/linux/if_macvlan.h
> +++ b/include/linux/if_macvlan.h
> @@ -50,7 +50,7 @@ struct macvlan_pcpu_stats {
>   * Maximum times a macvtap device can be opened. This can be used to
>   * configure the number of receive queue, e.g. for multiqueue virtio.
>   */
> -#define MAX_MACVTAP_QUEUES	(NR_CPUS < 16 ? NR_CPUS : 16)
> +#define MAX_MACVTAP_QUEUES	8
>  
>  #define MACVLAN_MC_FILTER_BITS	8
>  #define MACVLAN_MC_FILTER_SZ	(1 << MACVLAN_MC_FILTER_BITS)
> -- 
> 1.7.1
